# Build stage for client
FROM node:18-alpine AS client-builder
WORKDIR /app
COPY client/package*.json ./client/
WORKDIR /app/client
RUN npm ci --only=production
COPY client/ .
RUN npm run build

# Build stage for admin panel
FROM node:18-alpine AS admin-builder
WORKDIR /app
COPY admin-panel/package*.json ./admin-panel/
WORKDIR /app/admin-panel
RUN npm ci --only=production
COPY admin-panel/ .
RUN npm run build

# Final production image
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    sox \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

# Create app directory and set permissions
RUN addgroup -S appuser && adduser -S appuser -G appuser
WORKDIR /app

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy built client and admin panel
COPY --from=client-builder /app/client/build ./client/build
COPY --from=admin-builder /app/admin-panel/build ./admin-panel/build

# Copy server files
COPY server/ ./server/
COPY config/ ./config/
COPY .sequelizerc ./

# Create necessary directories with correct permissions
RUN mkdir -p /app/data /app/logs /app/uploads /app/downloads /app/processed /app/temp /app/overlays /app/credentials \
    && chown -R appuser:appuser /app \
    && chmod -R 755 /app

# Copy startup script and set permissions
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Expose ports (3000 for API, 3001 for admin panel)
EXPOSE 3000 3001

# Start command
CMD ["/app/startup.sh"]
