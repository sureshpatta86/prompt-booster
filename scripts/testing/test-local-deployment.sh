#!/bin/bash

# Local Deployment Test Script
# Tests the Docker build and health check locally before deploying

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONTAINER_NAME="prompt-booster-test"
IMAGE_NAME="prompt-booster"
PORT=3000

echo -e "${YELLOW}🧪 Testing Local Deployment...${NC}"

# Clean up any existing container
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "🧹 Cleaning up existing container..."
    docker stop $CONTAINER_NAME > /dev/null 2>&1 || true
    docker rm $CONTAINER_NAME > /dev/null 2>&1 || true
fi

# Build the image
echo "🏗️  Building Docker image..."
docker build -t $IMAGE_NAME . || {
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
}

# Run the container
echo "🚀 Starting container..."
docker run -d -p $PORT:$PORT --name $CONTAINER_NAME $IMAGE_NAME || {
    echo -e "${RED}❌ Failed to start container${NC}"
    exit 1
}

# Wait for container to be ready
echo "⏳ Waiting for container to be ready..."
sleep 5

# Test health endpoint
echo "🩺 Testing health endpoint..."
for i in {1..10}; do
    if curl -f -s "http://localhost:$PORT/api/health" > /dev/null; then
        echo -e "${GREEN}✅ Health check passed!${NC}"
        
        # Show health response
        echo "Health response:"
        curl -s "http://localhost:$PORT/api/health" | jq . || curl -s "http://localhost:$PORT/api/health"
        break
    fi
    
    if [ $i -eq 10 ]; then
        echo -e "${RED}❌ Health check failed after 10 attempts${NC}"
        echo "Container logs:"
        docker logs $CONTAINER_NAME
        exit 1
    fi
    
    echo "⏳ Attempt $i/10: Waiting for health endpoint..."
    sleep 2
done

# Test main page
echo "🌐 Testing main page..."
if curl -f -s "http://localhost:$PORT" > /dev/null; then
    echo -e "${GREEN}✅ Main page accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Main page not accessible (might be expected for API-only apps)${NC}"
fi

# Show container info
echo "📊 Container information:"
docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo -e "${GREEN}🎉 Local deployment test completed successfully!${NC}"
echo "📱 App is running at: http://localhost:$PORT"
echo "🩺 Health check: http://localhost:$PORT/api/health"
echo
echo "To stop the test container:"
echo "  docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
