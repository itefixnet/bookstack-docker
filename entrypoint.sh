#!/bin/bash

# BookStack entrypoint script
# Handles admin account and SQLite database configuration via environment variables

set -e

# Check required environment variables
if [ -z "$BOOKSTACK_ADMIN_EMAIL" ]; then
    echo "ERROR: BOOKSTACK_ADMIN_EMAIL environment variable is required"
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
ADMIN_EMAIL="$BOOKSTACK_ADMIN_EMAIL"
ADMIN_PASSWORD="$BOOKSTACK_ADMIN_PASSWORD"
ADMIN_NAME="${BOOKSTACK_ADMIN_NAME:-Admin}"
APP_URL="${BOOKSTACK_APP_URL:-http://localhost:8080}"

# Database configuration
DB_HOST="${DB_HOST:-mariadb}"
DB_PORT="${DB_PORT:-3306}"
DB_DATABASE="${DB_DATABASE:-bookstack}"
DB_USERNAME="${DB_USERNAME:-bookstack}"
DB_PASSWORD="${DB_PASSWORD:-bookstack}"

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

# Wait for database to be ready (if using external DB)
if [ -n "$DB_HOST" ]; then
    echo "Waiting for database at $DB_HOST:$DB_PORT..."
    for i in {1..30}; do
        if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
            echo "Database is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "Warning: Database not responding after 30 seconds, continuing anyway..."
        fi
        sleep 1
    done
fi

# Create necessary directories
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

# Create .env file with MySQL/MariaDB configuration
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

# Database Configuration (MySQL/MariaDB)
DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD

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
chmod 644 "$ENV_FILE"

echo "Environment file configured"

# Clear any cached config to ensure .env is read fresh
rm -f /var/www/html/bootstrap/cache/config.php

# Function to initialize database and create admin user
initialize_bookstack() {
    cd /var/www/html
    
    # Check if database is already initialized
    echo "Checking database status..."
    TABLE_COUNT=$(su -s /bin/bash -c "cd /var/www/html && php artisan tinker --execute='echo \\DB::table(\"migrations\")->count();'" www-data 2>/dev/null || echo "0")
    
    if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
        echo "Initializing database..."
        
        # Run migrations as www-data user
        echo "Running database migrations..."
        su -s /bin/bash -c "cd /var/www/html && php artisan migrate --force --no-interaction" www-data
        
        # Create/update admin user using --initial flag
        # This will update the default admin@admin.com user if it exists
        echo "Setting up admin user: $ADMIN_NAME ($ADMIN_EMAIL)"
        su -s /bin/bash -c "cd /var/www/html && php artisan bookstack:create-admin --email=\"$ADMIN_EMAIL\" --name=\"$ADMIN_NAME\" --password=\"$ADMIN_PASSWORD\" --initial" www-data
        
        echo "BookStack initialization completed!"
    else
        echo "Database already initialized, running migrations if needed..."
        su -s /bin/bash -c "cd /var/www/html && php artisan migrate --force --no-interaction" www-data
        
        echo "Database and admin user already configured."
    fi
    
    # Clear and optimize cache as www-data user
    echo "Optimizing application..."
    su -s /bin/bash -c "cd /var/www/html && php artisan cache:clear" www-data
    su -s /bin/bash -c "cd /var/www/html && php artisan config:clear" www-data
    su -s /bin/bash -c "cd /var/www/html && php artisan view:clear" www-data
    
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
