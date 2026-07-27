#!/bin/bash
set -e

APP_DIR="/var/www/prebid-cache"
CONTAINER_NAME="prebid-cache"
IMAGE_NAME="tpc/prebid-cache:latest"

echo "[deploy] $(date) — starting deploy on $(hostname)"

echo "[deploy] Building Docker image from ${APP_DIR}/src ..."
docker build --build-arg TEST=false -t "${IMAGE_NAME}" "${APP_DIR}/src"

echo "[deploy] Stopping old container (if running)..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm   "${CONTAINER_NAME}" 2>/dev/null || true

echo "[deploy] Starting new container..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p 127.0.0.1:2424:2424 \
  -p 127.0.0.1:2525:2525 \
  "${IMAGE_NAME}"

echo "[deploy] Done — container status:"
docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "[deploy] Pruning dangling images..."
docker image prune -f
