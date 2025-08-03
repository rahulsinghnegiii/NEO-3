# Create README.md
$readmeContent = @"
# NEO-3 Production Deployment

## Prerequisites
- Docker
- Docker Compose

## Setup
1. Edit the [.env](cci:7://file:///g:/Freelancing%20PROJECTS%20DEV/WORK/sandy/2/NEO-3/.env:0:0-0:0) file with your production settings
2. Make sure all required directories have proper permissions:
   - `data/` - For database storage
   - [logs/](cci:1://file:///g:/Freelancing%20PROJECTS%20DEV/WORK/sandy/2/NEO-3/deploy.sh:71:0-74:1) - For application logs
   - `uploads/` - For file uploads
   - `processed/` - For processed files

## Running the Application
```bash
docker-compose up -d --build