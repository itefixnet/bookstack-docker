#!/bin/bash

# BookStack entrypoint script
# Handles admin account and SQLite database configuration via environment variables

set -e

# Check required environment variables
if [ -z "$BOOKSTACK_ADMIN_USER" ]; then
    echo "ERROR: BOOKSTACK_ADMIN_USER environment variable is required"
    exit 1
fi

if [ -z "$BOOKSTACK_ADMIN_PASSWORD" ]; then
    echo "ERROR: BOOKSTACK_ADMIN_PASSWORD environment variable is required"
    exit 1
fi

if [ -z "$TZ" ]; then
    echo "ERROR: TZ (timezone) environment variable is required"
    echo "See: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
    exit 1
fi

# Use environment variables
ADMIN_USER="$BOOKSTACK_ADMIN_USER"
ADMIN_EMAIL="${ADMIN_USER}@bookstack.local"
ADMIN_PASSWORD="$BOOKSTACK_ADMIN_PASSWORD"
ADMIN_NAME="${BOOKSTACK_ADMIN_NAME:-Admin}"
APP_URL="${BOOKSTACK_APP_URL:-http://localhost:8080}"

# Set timezone
echo "Setting timezone to: $TZ"
echo "$TZ" > /etc/timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

# Configure PHP with timezone
echo "Configuring PHP settings..."
{
    echo "date.timezone = $TZ"
    echo "memory_limit = 256M"
    echo "upload_max_filesize = 50M"
    echo "post_max_size = 50M"
    echo "max_execution_time = 120"
} > /usr/local/etc/php/conf.d/bookstack.ini

# Wait for file system to be ready
sleep 2

# Create necessary directories
mkdir -p /var/www/html/storage/database
mkdir -p /var/www/html/storage/uploads
mkdir -p /var/www/html/public/uploads

# Set permissions
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache
chown -R www-data:www-data /var/www/html/public/uploads
chmod -R 755 /var/www/html/storage
chmod -R 755 /var/www/html/bootstrap/cache
chmod -R 755 /var/www/html/public/uploads

# Create or update .env file
ENV_FILE="/var/www/html/.env"

echo "Configuring BookStack environment..."

# Generate APP_KEY if not exists
if [ ! -f "$ENV_FILE" ] || ! grep -q "APP_KEY=" "$ENV_FILE" 2>/dev/null || [ "$(grep "APP_KEY=" "$ENV_FILE" | cut -d'=' -f2)" = "" ]; then
    echo "Generating new application key..."
    APP_KEY=$(php artisan key:generate --show)
else
    APP_KEY=$(grep "APP_KEY=" "$ENV_FILE" | cut -d'=' -f2)
fi

# Create .env file with SQLite configuration
cat > "$ENV_FILE" << EOF
# Application Configuration
APP_NAME=BookStack
APP_ENV=production
APP_KEY=$APP_KEY
APP_URL=$APP_URL
APP_DEBUG=false
APP_LANG=en
APP_AUTO_LANG_PUBLIC=true
APP_TIMEZONE=$TZ

# Database Configuration (SQLite)
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/storage/database/database.sqlite

# Mail Configuration (optional - configure later)
MAIL_DRIVER=smtp
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_FROM=bookstack@example.com
MAIL_FROM_NAME=BookStack
MAIL_ENCRYPTION=tls
MAIL_USERNAME=null
MAIL_PASSWORD=null

# Cache and Session
CACHE_DRIVER=file
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=false

# Queue Configuration
QUEUE_CONNECTION=sync

# Storage
STORAGE_TYPE=local
STORAGE_URL=

# Authentication
AUTH_METHOD=standard
AUTH_AUTO_INITIATE=false

# File Upload Limits
FILE_UPLOAD_SIZE_LIMIT=50
DRAWIO=true

# Disable public registration by default
ALLOW_CONTENT_SCRIPTS=false
ALLOW_REGISTRATION=false
EOF

chown www-data:www-data "$ENV_FILE"
chmod 640 "$ENV_FILE"

echo "Environment file configured"

# Function to initialize database and create admin user
initialize_bookstack() {
    cd /var/www/html
    
    # Create SQLite database file if it doesn't exist
    if [ ! -f /var/www/html/storage/database/database.sqlite ]; then
        echo "Creating SQLite database..."
        touch /var/www/html/storage/database/database.sqlite
        chown www-data:www-data /var/www/html/storage/database/database.sqlite
        chmod 644 /var/www/html/storage/database/database.sqlite
        
        # Run migrations
        echo "Running database migrations..."
        php artisan migrate --force --no-interaction
        
        # Create admin user
        echo "Creating admin user: $ADMIN_USER (email: $ADMIN_EMAIL)"
        php artisan bookstack:create-admin --email="$ADMIN_EMAIL" --name="$ADMIN_NAME" --password="$ADMIN_PASSWORD"
        
        echo "BookStack initialization completed!"
    else
        echo "Database already exists, running migrations if needed..."
        php artisan migrate --force --no-interaction
        
        # Update admin password if requested
        if [ "$BOOKSTACK_UPDATE_ADMIN_PASSWORD" = "true" ]; then
            echo "Updating admin password..."
            php artisan bookstack:reset-password --email="$ADMIN_EMAIL" --password="$ADMIN_PASSWORD"
        fi
    fi
    
    # Clear and optimize cache
    echo "Optimizing application..."
    php artisan cache:clear
    php artisan config:clear
    php artisan view:clear
    
    echo "BookStack is ready!"
}

# Initialize BookStack in background after Apache starts
(
    sleep 5
    initialize_bookstack
) &

# Start Apache in foreground
echo "Starting Apache web server..."
exec apache2-foreground
