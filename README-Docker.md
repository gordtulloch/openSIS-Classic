# openSIS Classic Docker Setup

This Docker setup provides a complete environment for running openSIS Classic with Apache 2.2-compatible server, MySQL 5.7, and PHP 5.5 (closest available to PHP 5.2).

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Clone or navigate to the openSIS Classic directory**
   ```bash
   cd /path/to/openSIS-Classic
   ```

2. **Build and start the containers**
   ```bash
   docker-compose up -d
   ```

3. **Wait for containers to initialize** (first run may take several minutes)

4. **Access the application**
   - openSIS: http://localhost:8080
   - phpMyAdmin: http://localhost:8081

## Container Details

### Web Server (opensis-web)
- **Base Image**: Ubuntu 14.04
- **Web Server**: Apache 2.2
- **PHP Version**: 5.5 (closest available to 5.2)
- **Port**: 8080 (mapped to container port 80)

### Database Server (opensis-db)
- **Image**: MySQL 5.7
- **Port**: 3306
- **Database**: opensis
- **Username**: opensis_user
- **Password**: opensis_pass
- **Root Password**: root_password

### phpMyAdmin (phpmyadmin)
- **Port**: 8081
- **Username**: root
- **Password**: root_password

## Configuration

### Database Connection
The database connection is automatically configured through environment variables:
- `DB_HOST=opensis-db`
- `DB_PORT=3306`
- `DB_NAME=opensis`
- `DB_USER=opensis_user`
- `DB_PASSWORD=opensis_pass`

### PHP Configuration
Custom PHP settings are applied for optimal openSIS performance:
- Memory limit: 512M
- Upload limit: 50M
- Execution time: 300 seconds
- MySQL extensions enabled

## Initial Setup

1. **Access openSIS**: Navigate to http://localhost:8080
2. **Run the installer**: Follow the web-based installation wizard
3. **Database settings**: Use the following configuration:
   - Database Type: MySQL/MySQLi
   - Database Server: opensis-db
   - Database Name: opensis
   - Username: opensis_user
   - Password: opensis_pass

## File Structure

```
openSIS-Classic/
├── docker/
│   ├── apache-opensis.conf    # Apache virtual host configuration
│   ├── supervisord.conf       # Supervisor configuration
│   └── php.ini               # Custom PHP configuration
├── docker-compose.yml        # Docker Compose configuration
├── Dockerfile               # Docker image build instructions
├── Data.php                # Database configuration file
└── README-Docker.md        # This file
```

## Development

### Accessing Files
The project directory is mounted as a volume, so any changes made to the source files will be immediately reflected in the running container.

### Database Access
- **Via phpMyAdmin**: http://localhost:8081
- **Direct MySQL connection**: localhost:3306

### Logs
View container logs:
```bash
# Web server logs
docker-compose logs opensis-web

# Database logs
docker-compose logs opensis-db

# All logs
docker-compose logs
```

## Stopping and Starting

### Stop containers
```bash
docker-compose down
```

### Start containers
```bash
docker-compose up -d
```

### Rebuild containers (after changes to Dockerfile)
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

### Port Conflicts
If ports 8080, 8081, or 3306 are in use, modify the port mappings in `docker-compose.yml`:
```yaml
ports:
  - "9080:80"  # Change 8080 to 9080
```

### Database Connection Issues
1. Ensure all containers are running: `docker-compose ps`
2. Check database container logs: `docker-compose logs opensis-db`
3. Verify database credentials in `Data.php`

### Permission Issues
If you encounter file permission issues:
```bash
# Fix permissions (run from the openSIS directory)
sudo chown -R $USER:$USER .
chmod -R 755 .
```

### Container Issues
Restart specific containers:
```bash
# Restart web server
docker-compose restart opensis-web

# Restart database
docker-compose restart opensis-db
```

## Production Considerations

For production deployment:

1. **Change default passwords** in `docker-compose.yml`
2. **Disable debug mode** in `Data.php`
3. **Configure SSL/HTTPS**
4. **Set up proper backup procedures**
5. **Configure email settings** in `Data.php`
6. **Implement proper security measures**

## Support

For openSIS-specific issues, refer to:
- [openSIS Documentation](https://www.os4ed.com/)
- [GitHub Repository](https://github.com/OS4ED/openSIS-Classic)

For Docker-related issues:
- Check container logs
- Verify Docker and Docker Compose versions
- Ensure sufficient system resources
