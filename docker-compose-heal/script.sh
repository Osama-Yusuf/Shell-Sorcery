#!/bin/bash

# Configurable variables
ENDPOINT="https://example.com"
DOCKER_CONTAINER_NAME="client"
DOCKER_COMPOSE_DIR="/home/ubuntu/client"

# Interval variables for high customization
INITIAL_WAIT=10              # Time to wait before the first container status recheck (in seconds)
POST_START_WAIT=10           # Time to wait after starting the container before checking status again (in seconds)
FINAL_ENDPOINT_CHECK_WAIT=5  # Time to wait before the final endpoint check after container start (in seconds)

# Function to check the HTTP status code
check_http_status() {
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$ENDPOINT")
    echo "HTTP Status: $HTTP_STATUS"
    if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
        echo "✅ Endpoint is healthy."
        exit 0
    else
        echo "⚠️  Endpoint returned status $HTTP_STATUS. Proceeding to check container status."
    fi
}

# Function to check if the Docker container is running
check_container_status() {
    CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' "$DOCKER_CONTAINER_NAME" 2>/dev/null || echo "not_found")
    echo "Container Status: $CONTAINER_STATUS"
    if [ "$CONTAINER_STATUS" != "running" ]; then
        return 1  # Container is not running
    else
        return 0  # Container is running
    fi
}

# Main script execution
check_http_status

if ! check_container_status; then
    echo "⚠️  Container '$DOCKER_CONTAINER_NAME' is not running. Waiting $INITIAL_WAIT seconds before rechecking..."
    sleep "$INITIAL_WAIT"
    if ! check_container_status; then
        echo "❌ Container '$DOCKER_CONTAINER_NAME' is still not running. Attempting to start it."
        cd "$DOCKER_COMPOSE_DIR" || { echo "❌ Failed to change directory to $DOCKER_COMPOSE_DIR"; exit 1; }
        docker compose up -d || { echo "❌ Failed to start Docker container '$DOCKER_CONTAINER_NAME'"; exit 1; }
        echo "⏳ Waiting $POST_START_WAIT seconds for the container to initialize..."
        sleep "$POST_START_WAIT"
        if check_container_status; then
            echo "✅ Container '$DOCKER_CONTAINER_NAME' is now running."
            echo "⏳ Waiting $FINAL_ENDPOINT_CHECK_WAIT seconds before hitting the endpoint..."
            sleep "$FINAL_ENDPOINT_CHECK_WAIT"
            echo "🌐 Hitting the endpoint..."
            check_http_status
        else
            echo "❌ Failed to start container '$DOCKER_CONTAINER_NAME' after docker-compose up."
            exit 1
        fi
    else
        echo "✅ Container '$DOCKER_CONTAINER_NAME' started running after waiting."
    fi
else
    echo "✅ Container '$DOCKER_CONTAINER_NAME' is running."
fi
