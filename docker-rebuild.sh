#!/bin/bash

# Script to clean up dangling containers and rebuild the snappass image

echo "Stopping and removing snappass containers..."
docker ps -a -q --filter ancestor=rjpr/snappass | xargs -r docker rm -f

echo "Removing dangling images..."
docker image prune -f

echo "Rebuilding with docker compose..."
docker compose up --build

