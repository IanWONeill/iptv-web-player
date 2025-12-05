<?php
/**
 * PHP Backend - CORS Proxy (Optional)
 * Alternative PHP-based proxy for handling CORS
 * 
 * Note: Cloudflare Worker is preferred, but this can serve as a fallback
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Range');
header('Access-Control-Expose-Headers: Content-Length, Content-Range, Accept-Ranges');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get target URL from query parameter
$targetUrl = $_GET['url'] ?? '';

if (empty($targetUrl)) {
    http_response_code(400);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Missing url parameter']);
    exit;
}

// Validate URL
if (!filter_var($targetUrl, FILTER_VALIDATE_URL)) {
    http_response_code(400);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Invalid URL']);
    exit;
}

// Initialize cURL
$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_URL => $targetUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_MAXREDIRS => 5,
    CURLOPT_TIMEOUT => 30,
    CURLOPT_SSL_VERIFYPEER => false,
    CURLOPT_USERAGENT => $_SERVER['HTTP_USER_AGENT'] ?? 'Mozilla/5.0',
    CURLOPT_HEADERFUNCTION => function($curl, $header) {
        $len = strlen($header);
        $header = explode(':', $header, 2);
        
        if (count($header) >= 2) {
            $name = strtolower(trim($header[0]));
            $value = trim($header[1]);
            
            // Forward relevant headers
            $forwardHeaders = [
                'content-type',
                'content-length',
                'content-range',
                'accept-ranges',
            ];
            
            if (in_array($name, $forwardHeaders)) {
                header("$name: $value");
            }
        }
        
        return $len;
    }
]);

// Handle Range requests for video seeking
if (isset($_SERVER['HTTP_RANGE'])) {
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Range: ' . $_SERVER['HTTP_RANGE']
    ]);
}

// Execute request
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

// Handle errors
if ($error) {
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Proxy error: ' . $error]);
    exit;
}

// Check if this is an M3U8 playlist
$isM3u8 = strpos($targetUrl, '.m3u8') !== false || 
          strpos($response, '#EXTM3U') === 0;

// Rewrite M3U8 segment URLs if needed
if ($isM3u8 && $httpCode === 200) {
    $response = rewriteM3u8($response, $targetUrl);
    header('Content-Type: application/vnd.apple.mpegurl');
}

// Set status code and output response
http_response_code($httpCode);
echo $response;

/**
 * Rewrite M3U8 playlist segment URLs to proxy through this script
 */
function rewriteM3u8($content, $baseUrl) {
    $lines = explode("\n", $content);
    $rewritten = [];
    $baseUrlParsed = parse_url($baseUrl);
    $baseUrlDir = dirname($baseUrlParsed['path']);
    
    foreach ($lines as $line) {
        $trimmed = trim($line);
        
        // Skip comments and empty lines
        if (empty($trimmed) || $trimmed[0] === '#') {
            $rewritten[] = $line;
            continue;
        }
        
        // This is a segment URL
        $segmentUrl = $trimmed;
        
        // Resolve relative URLs
        if (strpos($segmentUrl, 'http://') !== 0 && strpos($segmentUrl, 'https://') !== 0) {
            $scheme = $baseUrlParsed['scheme'];
            $host = $baseUrlParsed['host'];
            $port = isset($baseUrlParsed['port']) ? ':' . $baseUrlParsed['port'] : '';
            
            if ($segmentUrl[0] === '/') {
                $segmentUrl = "$scheme://$host$port$segmentUrl";
            } else {
                $segmentUrl = "$scheme://$host$port$baseUrlDir/$segmentUrl";
            }
        }
        
        // Proxy the segment URL through this script
        $proxyUrl = $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER['HTTP_HOST'] . 
                    $_SERVER['SCRIPT_NAME'] . '?url=' . urlencode($segmentUrl);
        
        $rewritten[] = $proxyUrl;
    }
    
    return implode("\n", $rewritten);
}
