#!/bin/bash

# Alternative Azure Container Apps Deployment Script
# Use this if the GitHub Actions workflow continues to fail

set -e

# Configuration
RESOURCE_GROUP="rg-prompt-booster"
CONTAINER_APP_NAME="prompt-booster-production"
ACR_NAME="acrpromptboosterproduction"
IMAGE_NAME="prompt-booster"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Alternative Azure Container Apps Deployment${NC}"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

# Get the latest image tag
IMAGE_TAG="${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest"
echo -e "${YELLOW}📦 Using image: $IMAGE_TAG${NC}"

# Method 1: Try the standard update approach
echo -e "${YELLOW}🔄 Attempting standard container app update...${NC}"
if az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --image $IMAGE_TAG \
    --min-replicas 1 \
    --max-replicas 5 \
    --cpu 0.75 \
    --memory 1.5Gi \
    --replace-env-vars \
      NODE_ENV=production \
      NEXT_TELEMETRY_DISABLED=1 \
      PORT=3000; then
    
    echo -e "${GREEN}✅ Standard update successful${NC}"
    
    # Ensure ingress is configured
    echo -e "${YELLOW}🌐 Configuring ingress...${NC}"
    az containerapp ingress enable \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --type external \
        --target-port 3000 \
        --transport http || echo "Ingress might already be configured"
        
else
    echo -e "${YELLOW}⚠️  Standard update failed, trying revision-based approach...${NC}"
    
    # Method 2: Create a new revision
    REVISION_SUFFIX=$(date +%s)
    
    az containerapp revision copy \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --from-revision latest \
        --image $IMAGE_TAG \
        --revision-suffix $REVISION_SUFFIX
    
    # Activate the new revision
    az containerapp revision activate \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --revision "${CONTAINER_APP_NAME}--${REVISION_SUFFIX}"
        
    echo -e "${GREEN}✅ Revision-based deployment successful${NC}"
fi

# Get the application URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    --output tsv)

if [ -n "$APP_URL" ]; then
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo -e "${GREEN}🌐 Application URL: https://$APP_URL${NC}"
    
    # Test the health endpoint
    echo -e "${YELLOW}🩺 Testing health endpoint...${NC}"
    if curl -f -s "https://$APP_URL/api/health" > /dev/null; then
        echo -e "${GREEN}✅ Health check passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Health check failed - app might still be starting${NC}"
    fi
else
    echo -e "${RED}❌ Could not retrieve application URL${NC}"
fi
