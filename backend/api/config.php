<?php
/**
 * PHP Backend - Configuration API
 * Provides remote UI control and service spinner data
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Load configuration
$configFile = __DIR__ . '/../config/settings.json';

if (!file_exists($configFile)) {
    http_response_code(500);
    echo json_encode(['error' => 'Configuration file not found']);
    exit;
}

$config = json_decode(file_get_contents($configFile), true);

if ($config === null) {
    http_response_code(500);
    echo json_encode(['error' => 'Invalid configuration file']);
    exit;
}

// Return configuration
http_response_code(200);
echo json_encode([
    'success' => true,
    'data' => [
        'app_name' => $config['app_name'] ?? 'IPTV Player',
        'logo_url' => $config['logo_url'] ?? '',
        'primary_color' => $config['primary_color'] ?? '#1a73e8',
        'accent_color' => $config['accent_color'] ?? '#00bcd4',
        'features' => $config['features'] ?? [],
        'version' => $config['version'] ?? '1.0.0',
    ]
]);
