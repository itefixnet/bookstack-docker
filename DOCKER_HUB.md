# BookStack Docker Container

A Docker container for [BookStack](https://www.bookstackapp.com/) - a simple, self-hosted platform for organizing and storing information.

BookStack is an opinionated wiki system that provides a pleasant and simple out-of-the-box experience. New users to an instance should find the experience intuitive and only basic word-processing skills should be required to get involved in creating content.

## Features

- **Apache-based**: Built on PHP 8.2 with Apache web server
- **BookStack v25.11.4**: Latest stable release
- **Customizable Admin**: Configure admin email and password via environment variables
- **MySQL/MariaDB Support**: Works with external MySQL or MariaDB databases
- **Timezone Support**: Configure your preferred timezone
- **Persistent Storage**: Two volume mount points for uploads
- **Health Checks**: Built-in container health monitoring
- **Automatic Updates**: Admin credentials update on every container start

## Quick Start

```bash
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -e BOOKSTACK_APP_URL=http://localhost:8080 \
  -e BOOKSTACK_ADMIN_EMAIL=admin@example.com \
  -e BOOKSTACK_ADMIN_PASSWORD=your-secure-password \
  -e TZ=Europe/Amsterdam \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=your-db-password \
  -v bookstack_storage:/var/www/html/storage/uploads \
  -v bookstack_public:/var/www/html/public/uploads \
  itefixnet/bookstack:latest
```

Access BookStack at `http://localhost:8080` and login with your configured admin credentials.

## Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `BOOKSTACK_APP_URL` | The base URL of your BookStack instance | `http://localhost:8080` |
| `BOOKSTACK_ADMIN_EMAIL` | Admin user email address | `admin@example.com` |
| `BOOKSTACK_ADMIN_PASSWORD` | Admin user password | `your-secure-password` |
| `TZ` | Timezone for the container | `Europe/Amsterdam` |
| `DB_HOST` | MySQL/MariaDB host | `mysql` or `192.168.1.10` |
| `DB_DATABASE` | Database name | `bookstack` |
| `DB_USERNAME` | Database username | `bookstack` |
| `DB_PASSWORD` | Database password | `your-db-password` |

> **Note**: All variables are required. There are no default values.

## Database Requirements

BookStack requires a MySQL or MariaDB database. You need to provide an external database connection.

### Example with MySQL Container

```bash
# Create a network
docker network create bookstack-net

# Start MySQL
docker run -d \
  --name bookstack-mysql \
  --network bookstack-net \
  -e MYSQL_ROOT_PASSWORD=root-password \
  -e MYSQL_DATABASE=bookstack \
  -e MYSQL_USER=bookstack \
  -e MYSQL_PASSWORD=bookstack-password \
  -v mysql_data:/var/lib/mysql \
  mysql:8.0

# Start BookStack
docker run -d \
  --name bookstack \
  --network bookstack-net \
  -p 8080:80 \
  -e BOOKSTACK_APP_URL=http://localhost:8080 \
  -e BOOKSTACK_ADMIN_EMAIL=admin@example.com \
  -e BOOKSTACK_ADMIN_PASSWORD=SecurePass123! \
  -e TZ=Europe/Amsterdam \
  -e DB_HOST=bookstack-mysql \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=bookstack-password \
  -v bookstack_storage:/var/www/html/storage/uploads \
  -v bookstack_public:/var/www/html/public/uploads \
  itefixnet/bookstack:latest
```

## Volume Mounts

The container uses two volumes for persistent storage:

- `/var/www/html/storage/uploads` - Internal storage for uploaded files
- `/var/www/html/public/uploads` - Public uploads accessible via web

## Supported Tags

- `latest` - Latest stable release (currently v25.11.4)
- `v25.11.4` - Specific BookStack version

## Additional Configuration

You can pass additional BookStack environment variables as needed. See the [BookStack documentation](https://www.bookstackapp.com/docs/) for all available options.

Example with LDAP authentication:

```bash
docker run -d \
  --name bookstack \
  -p 8080:80 \
  -e BOOKSTACK_APP_URL=http://localhost:8080 \
  -e BOOKSTACK_ADMIN_EMAIL=admin@example.com \
  -e BOOKSTACK_ADMIN_PASSWORD=your-password \
  -e TZ=Europe/Amsterdam \
  -e DB_HOST=mysql \
  -e DB_DATABASE=bookstack \
  -e DB_USERNAME=bookstack \
  -e DB_PASSWORD=bookstack-password \
  -e AUTH_METHOD=ldap \
  -e LDAP_SERVER=ldap.example.com \
  -e LDAP_BASE_DN="dc=example,dc=com" \
  -v bookstack_storage:/var/www/html/storage/uploads \
  -v bookstack_public:/var/www/html/public/uploads \
  itefixnet/bookstack:latest
```

## Timezone Configuration

The container supports timezone configuration via the `TZ` environment variable. See [TIMEZONES.md](https://github.com/itefixnet/bookstack-docker/blob/main/TIMEZONES.md) for a list of valid timezone values.

## Troubleshooting

### Container fails to start

Check that all required environment variables are set:
```bash
docker logs bookstack
```

### Cannot connect to database

Ensure your database host is accessible from the container and credentials are correct. The container will wait up to 60 seconds for the database to become available.

### Permission issues with uploads

The container runs as `www-data` (UID 33). Ensure volume permissions allow this user to write.

## Source Code

Source code and Dockerfile available at: [github.com/itefixnet/bookstack-docker](https://github.com/itefixnet/bookstack-docker)

## License

This Docker container is provided under the MIT License. BookStack itself is licensed under the MIT License.

## Support

- **BookStack Documentation**: https://www.bookstackapp.com/docs/
- **BookStack GitHub**: https://github.com/BookStackApp/BookStack
- **Container Issues**: https://github.com/itefixnet/bookstack-docker/issues
