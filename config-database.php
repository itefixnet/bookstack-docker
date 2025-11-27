<?php

/**
 * Database configuration options.
 * Custom configuration with SQLite support for BookStack Docker.
 */

// MYSQL - Split out port from host if set
$mysqlHost = env('DB_HOST', 'localhost');
$mysqlHostExploded = explode(':', $mysqlHost);
$mysqlPort = env('DB_PORT', 3306);
$mysqlHostIpv6 = str_starts_with($mysqlHost, '[');
if ($mysqlHostIpv6 && str_contains($mysqlHost, ']:')) {
    $mysqlHost = implode(':', array_slice($mysqlHostExploded, 0, -1));
    $mysqlPort = intval(end($mysqlHostExploded));
} else if (!$mysqlHostIpv6 && count($mysqlHostExploded) > 1) {
    $mysqlHost = $mysqlHostExploded[0];
    $mysqlPort = intval($mysqlHostExploded[1]);
}

return [

    // Default database connection name.
    // Options: mysql, sqlite
    'default' => env('DB_CONNECTION', 'mysql'),

    // Available database connections
    'connections' => [

        'sqlite' => [
            'driver'                  => 'sqlite',
            'url'                     => env('DATABASE_URL'),
            'database'                => env('DB_DATABASE', database_path('database.sqlite')),
            'prefix'                  => '',
            'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
        ],

        'mysql' => [
            'driver'         => 'mysql',
            'url'            => env('DATABASE_URL'),
            'host'           => $mysqlHost,
            'database'       => env('DB_DATABASE', 'forge'),
            'username'       => env('DB_USERNAME', 'forge'),
            'password'       => env('DB_PASSWORD', ''),
            'unix_socket'    => env('DB_SOCKET', ''),
            'port'           => $mysqlPort,
            'charset'        => 'utf8mb4',
            'collation'      => 'utf8mb4_unicode_ci',
            'prefix'         => env('DB_TABLE_PREFIX', ''),
            'prefix_indexes' => true,
            'strict'         => false,
            'engine'         => null,
            'options'        => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],

        'mysql_testing' => [
            'driver'         => 'mysql',
            'url'            => env('TEST_DATABASE_URL'),
            'host'           => '127.0.0.1',
            'database'       => 'bookstack-test',
            'username'       => env('MYSQL_USER', 'bookstack-test'),
            'password'       => env('MYSQL_PASSWORD', 'bookstack-test'),
            'port'           => $mysqlPort,
            'charset'        => 'utf8mb4',
            'collation'      => 'utf8mb4_unicode_ci',
            'prefix'         => '',
            'prefix_indexes' => true,
            'strict'         => false,
        ],

    ],

    // Migration Repository Table
    'migrations' => 'migrations',

    // Redis configuration
    'redis' => [],

];
