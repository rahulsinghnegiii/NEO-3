# NEO-3 Production Deployment Guide

This guide explains how to deploy NEO-3 to a production environment on a Hetzner server.

## Prerequisites

- Docker and Docker Compose installed on the Hetzner server
- Git installed on the server
- Domain name pointing to your server's IP (recommended)
- SSL certificates (recommended, can be obtained using Let's Encrypt)

## Deployment Steps

1. **Transfer Files to Server**
   ```bash
   # On your local machine
   rsync -avz --exclude='node_modules' --exclude='.git' --exclude='.env*' ./ user@your-hetzner-ip:/opt/neo3/
   ```

2. **On the Server**
   ```bash
   # Create necessary directories
   sudo mkdir -p /opt/neo3
   sudo chown -R $USER:$USER /opt/neo3
   
   # Navigate to the project directory
   cd /opt/neo3
   
   # Create .env file from example
   cp .env.prod.example .env
   
   # Edit .env with your production values
   nano .env
   
   # Build and start the containers
   docker-compose -f docker-compose.prod.yml up -d --build
   ```

3. **Verify the Deployment**
   ```bash
   # Check container status
   docker ps
   
   # View logs
   docker logs neo3-app
   
   # Check health
   curl http://localhost:3000/health
   ```

4. **Set Up Reverse Proxy (Nginx Example)**
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com;
       return 301 https://$host$request_uri;
   }

   server {
       listen 443 ssl http2;
       server_name yourdomain.com;

       ssl_certificate /path/to/your/cert.pem;
       ssl_certificate_key /path/to/your/key.pem;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }

       location /admin {
           proxy_pass http://localhost:3001;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

## Maintenance

### Updating the Application
```bash
# Pull the latest changes
git pull

# Rebuild and restart the containers
docker-compose -f docker-compose.prod.yml up -d --build

# Run database migrations (if any)
docker-compose -f docker-compose.prod.yml exec app npx sequelize db:migrate
```

### Backup and Restore
```bash
# Backup database
cp /opt/neo3/data/db.sqlite /path/to/backup/db-$(date +%Y%m%d).sqlite

# Backup uploads
rsync -avz /opt/neo3/uploads/ /path/to/backup/uploads/
```

## Security Considerations

1. **Firewall**: Ensure your server's firewall only allows necessary ports (80, 443, 22)
2. **Updates**: Regularly update Docker and system packages
3. **Monitoring**: Set up monitoring for the application and server
4. **Backups**: Regularly back up the database and uploads
5. **Secrets**: Never commit sensitive information to version control

## Troubleshooting

### Common Issues

1. **Port Conflicts**
   - Ensure ports 3000 and 3001 are not in use by other services

2. **Permission Issues**
   - Ensure the app user has proper permissions on all directories:
     ```bash
     sudo chown -R 1000:1000 /opt/neo3/data /opt/neo3/logs /opt/neo3/uploads /opt/neo3/downloads /opt/neo3/processed /opt/neo3/temp /opt/neo3/overlays /opt/neo3/credentials
     ```

3. **Container Failing to Start**
   - Check logs: `docker logs neo3-app`
   - Check container status: `docker ps -a`

4. **Database Issues**
   - Check if the SQLite database is accessible
   - Run migrations if needed

For additional support, please refer to the project's documentation or open an issue.
