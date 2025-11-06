#!/bin/bash
set -e
echo "🚀 Starting playground..."
docker-compose down -v --remove-orphans
docker-compose up -d
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"