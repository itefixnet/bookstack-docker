# BookStack Docker Container

A Docker container for [BookStack](https://www.bookstackapp.com/) - a simple, self-hosted platform for organizing and storing information.

BookStack is an opinionated wiki system that provides a pleasant and simple out-of-the-box experience. New users to an instance should find the experience intuitive and only basic word-processing skills should be required to get involved in creating content.

## Features

- **PHP 8.2** with Apache web server
- **MySQL/MariaDB database support** (BookStack's officially supported databases)
- **All required PHP extensions** for BookStack functionality
- **Configurable admin credentials** via environment variables
- **Optimized configuration** for performance and security
- **Volume support** for persistent data storage
- **Health checks** included
- **Simple Docker setup**

## Quick Start

### Using Docker CLI

```bash
# Build the image
docker build -t bookstack .

# Run the container (admin credentials and timezone are REQUIRED)
# You must provide database connection details
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -v bookstack_uploads:/var/www/html/storage/uploads \
  -e BOOKSTACK_ADMIN_EMAIL=admin@example.com \
  -e BOOKSTACK_ADMIN_PASSWORD=changeme123 \
  -e BOOKSTACK_ADMIN_NAME=Admin \
  -e TZ=UTC \
  -e BOOKSTACK_APP_URL=http://localhost:8080 \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=your-db-password \
  --restart unless-stopped \
  bookstack
```

## Initial Setup

1. **Access BookStack**: Navigate to `http://localhost:8080`

2. **First Login**: 
   - Email: The email you set via `BOOKSTACK_ADMIN_EMAIL`
   - Password: The password you set via `BOOKSTACK_ADMIN_PASSWORD`

3. **Configure Settings**: 
   - Go to Settings (gear icon) to configure your BookStack instance
   - Update site name, registration settings, and other preferences

4. **Security**: 
   - Use a strong password from the start via `BOOKSTACK_ADMIN_PASSWORD`
   - Configure email settings for password resets and notifications
   - Consider changing the admin email address in BookStack settings after first login

## Configuration

### Environment Variables

#### Required Variables
- `BOOKSTACK_ADMIN_EMAIL`: Admin email address (**REQUIRED**)
- `BOOKSTACK_ADMIN_PASSWORD`: Admin password (**REQUIRED**)
- `TZ`: Timezone (**REQUIRED**) - See [TIMEZONES.md](TIMEZONES.md) or [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

#### Optional Variables
- `BOOKSTACK_ADMIN_NAME`: Admin display name (default: "Admin")
- `BOOKSTACK_APP_URL`: Application URL (default: "http://localhost:8080")
- `DB_HOST`: Database host (default: uses internal connection if not set)
- `DB_PORT`: Database port (default: 3306)
- `DB_DATABASE`: Database name (default: bookstack)
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password

### Volumes

- `/var/www/html/storage/uploads`: File uploads (images, attachments, etc.)
- `/var/www/html/public/uploads`: Public uploaded files

### Ports

- `80`: HTTP port (mapped to `8080` in the examples above)

## Database

**Important Note**: BookStack officially only supports MySQL/MariaDB databases. While this Docker image was initially designed to use SQLite for simplicity, BookStack's migrations are not compatible with SQLite.

**We recommend using an external MySQL/MariaDB database** for proper BookStack operation. You can:

1. Use a managed database service
2. Run a separate MariaDB container
3. Use an existing MySQL/MariaDB server on your network

Configure the database connection via environment variables:
- `DB_HOST` - Database host
- `DB_PORT` - Database port (default: 3306)
- `DB_DATABASE` - Database name
- `DB_USERNAME` - Database username
- `DB_PASSWORD` - Database password

## Security Considerations

1. **Use HTTPS**: Always use HTTPS in production (consider a reverse proxy like Traefik or nginx)
2. **Strong Passwords**: Use strong, unique passwords for the admin account
3. **Secure Volumes**: The database and uploads volumes contain sensitive information
4. **Regular Updates**: Keep the container updated with the latest BookStack version
5. **Disable Registration**: Public registration is disabled by default - enable only if needed
6. **Firewall**: Consider restricting access to the container/port

## Build Configuration

### Build Arguments

- `BOOKSTACK_VERSION`: BookStack version to download (default: v24.10.1)

```bash
# Build with default version
docker build -t bookstack .

# Build with specific version
docker build --build-arg BOOKSTACK_VERSION=v24.10 -t bookstack .

# Build with latest release
docker build --build-arg BOOKSTACK_VERSION=release -t bookstack .
```

**Note**: Check [BookStack releases](https://github.com/BookStackApp/BookStack/releases) for available versions.

## Advanced Configuration

### Configuration Examples

All required variables must be provided:

```bash
# Basic setup with required variables
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -v bookstack_uploads:/var/www/html/storage/uploads \
  -e BOOKSTACK_ADMIN_USER=admin \
  -e BOOKSTACK_ADMIN_PASSWORD=MySecurePass123! \
  -e TZ=Europe/London \
  -e DB_HOST=mariadb.example.com \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=dbpassword \
  --restart unless-stopped \
  bookstack

# With custom admin name and app URL
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -v bookstack_uploads:/var/www/html/storage/uploads \
  -e BOOKSTACK_ADMIN_USER=johndoe \
  -e BOOKSTACK_ADMIN_PASSWORD=MySecurePass123! \
  -e BOOKSTACK_ADMIN_NAME="John Doe" \
  -e BOOKSTACK_APP_URL=https://wiki.mycompany.com \
  -e TZ=America/Chicago \
  -e DB_HOST=db.internal \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack_user \
  -e DB_PASSWORD=secure_db_pass \
  --restart unless-stopped \
  bookstack
```

#### Timezone Reference
For a complete list of timezone identifiers, see:
- **[TIMEZONES.md](TIMEZONES.md)** - Common timezones included in this repository  
- **[Wikipedia List](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)** - Complete timezone database
- **[IANA Time Zone Database](https://www.iana.org/time-zones)** - Official timezone database

Common examples: `America/New_York`, `Europe/London`, `Asia/Tokyo`, `UTC`

**Note**: The container will not start without `BOOKSTACK_ADMIN_USER`, `BOOKSTACK_ADMIN_PASSWORD`, and `TZ` environment variables.

### Backup

To backup your BookStack uploads:

```bash
# Backup uploads
docker run --rm \
  -v bookstack_uploads:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/bookstack-uploads-$(date +%Y%m%d).tar.gz -C /data .
```

**Note**: Database backups should be done using your MySQL/MariaDB database backup tools (mysqldump, etc.).

### Restore from Backup

```bash
# Restore uploads
docker run --rm \
  -v bookstack_uploads:/data \
  -v $(pwd)/backup:/backup \
  alpine sh -c "cd /data && tar xzf /backup/bookstack-uploads-YYYYMMDD.tar.gz"
```

**Note**: Database restoration should be done using your MySQL/MariaDB database restore tools.

### Reset Admin Password

If you forget the admin password:

```bash
# Method 1: Set environment variable and restart
docker stop bookstack
docker rm bookstack
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -v bookstack_uploads:/var/www/html/storage/uploads \
  -e BOOKSTACK_ADMIN_USER=admin \
  -e BOOKSTACK_ADMIN_PASSWORD=NewPassword123 \
  -e BOOKSTACK_UPDATE_ADMIN_PASSWORD=true \
  -e TZ=UTC \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=your-db-password \
  bookstack

# Method 2: Use artisan command directly
docker exec -it bookstack php artisan bookstack:reset-password --email=admin@bookstack.local --password=NewPassword123
```

## System Requirements

- **PHP Extensions**: All required extensions are included in this Docker image
- **Memory**: 256MB RAM minimum, 512MB recommended
- **Database**: MySQL 5.7+ or MariaDB 10.2+ (external database required)
- **Storage**: 
  - ~200MB for application
  - Additional space for uploads (varies by usage)

## Troubleshooting

### Check Logs

```bash
# Container logs
docker logs bookstack

# Follow logs in real-time
docker logs -f bookstack

# Apache logs
docker exec bookstack tail -f /var/log/apache2/error.log
docker exec bookstack tail -f /var/log/apache2/access.log

# BookStack logs
docker exec bookstack tail -f /var/www/html/storage/logs/laravel.log
```

### Permission Issues

```bash
# Fix permissions if needed
docker exec bookstack chown -R www-data:www-data /var/www/html/storage
docker exec bookstack chown -R www-data:www-data /var/www/html/public/uploads
docker exec bookstack chmod -R 755 /var/www/html/storage
```

### Database Issues

```bash
# Test database connection
docker exec bookstack php artisan tinker --execute="echo DB::connection()->getPdo() ? 'Connected' : 'Failed';"

# Run migrations manually
docker exec bookstack php artisan migrate --force

# Clear cache
docker exec bookstack php artisan cache:clear
docker exec bookstack php artisan config:clear
docker exec bookstack php artisan view:clear
```

### Container Won't Start

1. Check that all required environment variables are set
2. Verify volumes are accessible
3. Check logs: `docker logs bookstack`
4. Ensure port 8080 (or your chosen port) is not already in use

## Updates

To update to a newer version of BookStack:

1. Backup your data (see Backup section above)
2. Update the `BOOKSTACK_VERSION` in the Dockerfile or docker-compose.yml
3. Rebuild and restart:

```bash
# Stop and remove old container
docker stop bookstack
docker rm bookstack

# Rebuild with new version
docker build --no-cache -t bookstack .

# Start with same volumes and database (data persists)
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -v bookstack_uploads:/var/www/html/storage/uploads \
  -e BOOKSTACK_ADMIN_USER=admin \
  -e BOOKSTACK_ADMIN_PASSWORD=changeme123 \
  -e TZ=UTC \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=your-db-password \
  --restart unless-stopped \
  bookstack
```

The entrypoint script will automatically run migrations on container start.

## Email Configuration

By default, email is not configured. To enable email notifications and password resets:

1. Access the container:
```bash
docker exec -it bookstack bash
```

2. Edit the `.env` file:
```bash
nano /var/www/html/.env
```

3. Update the mail settings:
```ini
MAIL_DRIVER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_FROM=your-email@gmail.com
MAIL_FROM_NAME=BookStack
MAIL_ENCRYPTION=tls
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

4. Restart the container:
```bash
docker restart bookstack
```

## Contributing

Feel free to contribute improvements, bug fixes, or feature requests.

## License

This Docker configuration is provided as-is under BSD 2-Clause License. BookStack itself is licensed under MIT License.

## Links

- [BookStack Official Website](https://www.bookstackapp.com/)
- [BookStack GitHub Repository](https://github.com/BookStackApp/BookStack)
- [BookStack Documentation](https://www.bookstackapp.com/docs/)
- [BookStack Demo](https://demo.bookstackapp.com/)

## Acknowledgments

This Docker solution is inspired by the [SnappyMail Docker](https://github.com/itefixnet/snappymail-docker) project structure.