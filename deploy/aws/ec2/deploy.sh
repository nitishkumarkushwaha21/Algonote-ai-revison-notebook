#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose.aws.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Missing $COMPOSE_FILE in current directory"
  exit 1
fi

echo "Pulling latest Docker images..."
docker compose -f "$COMPOSE_FILE" pull

echo "Recreating containers with latest images..."
docker compose -f "$COMPOSE_FILE" up -d --remove-orphans

echo "Current running services:"
docker compose -f "$COMPOSE_FILE" ps

echo "Pruning dangling images..."
docker image prune -f

echo "Deployment complete."
