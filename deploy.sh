#!/bin/bash
# Deploy PA Optimized Server to Remote (192.168.50.3)

set -e

REMOTE_USER="brandon"
REMOTE_HOST="192.168.50.3"
REMOTE_PATH="/home/brandon/pa-docker"

echo "═══════════════════════════════════════════════════════"
echo "  PA Server Optimized Deployment"
echo "  Target: ${REMOTE_USER}@${REMOTE_HOST}"
echo "═══════════════════════════════════════════════════════"
echo ""

# Step 1: Sync Docker files to remote
echo "[1/5] Syncing Docker configuration to remote..."
rsync -avz --progress \
    Dockerfile \
    docker-compose.yml \
    entrypoint.sh \
    ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/

# Step 2: Build image on remote
echo ""
echo "[2/5] Building Docker image on remote..."
ssh ${REMOTE_USER}@${REMOTE_HOST} << 'ENDSSH'
cd /home/brandon/pa-docker
docker build -f Dockerfile -t pa-optimized:latest .
ENDSSH

# Step 3: Stop existing server (if running)
echo ""
echo "[3/5] Stopping existing server..."
ssh ${REMOTE_USER}@${REMOTE_HOST} << 'ENDSSH'
killall server_bolt3 2>/dev/null || true
docker-compose -f docker-compose.yml down 2>/dev/null || true
sleep 2
ENDSSH

# Step 4: Start optimized server
echo ""
echo "[4/5] Starting optimized server..."
ssh ${REMOTE_USER}@${REMOTE_HOST} << 'ENDSSH'
cd /home/brandon/pa-docker
docker-compose -f docker-compose.yml up -d
ENDSSH

# Step 5: Health check
echo ""
echo "[5/5] Waiting for health check..."
sleep 10

ssh ${REMOTE_USER}@${REMOTE_HOST} << 'ENDSSH'
docker ps | grep pa-optimized
echo ""
echo "Container logs (last 20 lines):"
docker logs pa-optimized --tail 20
echo ""
echo "Health status:"
docker inspect pa-optimized --format='{{.State.Health.Status}}'
ENDSSH

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Monitor with:"
echo "  ssh ${REMOTE_USER}@${REMOTE_HOST} 'docker logs -f pa-optimized'"
echo ""
echo "Check CPU usage:"
echo "  ssh ${REMOTE_USER}@${REMOTE_HOST} 'docker stats pa-optimized'"
echo ""
