<?php
/**
 * PHP Backend - Services API
 * Provides service spinner dropdown data
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

// Return services list
$services = $config['services'] ?? [];

http_response_code(200);
echo json_encode([
    'success' => true,
    'data' => [
        'services' => $services,
        'allow_custom' => $config['allow_custom_service'] ?? true,
    ]
]);
