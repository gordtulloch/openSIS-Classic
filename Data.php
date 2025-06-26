<?php
/**
 * Database Configuration for openSIS Docker Environment
 * This file configures the database connection for Docker setup
 */

// Database configuration
$DatabaseType = 'mysqli';
$DatabaseServer = getenv('DB_HOST') ?: 'opensis-db';  // Docker service name
$DatabasePort = getenv('DB_PORT') ?: '3306';
$DatabaseName = getenv('DB_NAME') ?: 'opensis';
$DatabaseUsername = getenv('DB_USER') ?: 'opensis_user';
$DatabasePassword = getenv('DB_PASSWORD') ?: 'opensis_pass';

// Additional database settings
$DatabaseEncoding = 'utf8';

// Connection timeout
$DatabaseTimeout = 30;

// Enable persistent connections
$DatabasePersistent = false;

// Enable SSL connection (set to false for local development)
$DatabaseSSL = false;

// Default School Year (can be modified during installation)
$DefaultSyear = date('Y');

// Default time zone
date_default_timezone_set('UTC');

// Application settings
$openSISPath = dirname(__FILE__) . '/';
$openSISURL = 'http://localhost:8080/';

// File upload paths
$StudentPicturesPath = 'assets/studentphotos/';
$UserPicturesPath = 'assets/userphotos/';

// Security settings
$PasswordMinLength = 6;
$PasswordComplexity = false; // Set to true for stronger password requirements

// Email settings (configure as needed)
$EmailServer = '';
$EmailPort = 587;
$EmailUsername = '';
$EmailPassword = '';
$EmailSSL = true;

// Debug mode (set to false in production)
$DebugMode = true;

// Error reporting for development
if ($DebugMode) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// Session settings
ini_set('session.gc_maxlifetime', 3600); // 1 hour
ini_set('session.cookie_lifetime', 0);

// Memory and execution limits
ini_set('memory_limit', '512M');
ini_set('max_execution_time', 300);
ini_set('max_input_time', 300);

// File upload limits
ini_set('upload_max_filesize', '50M');
ini_set('post_max_size', '50M');

?>
