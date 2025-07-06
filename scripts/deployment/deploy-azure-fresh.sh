#!/bin/bash

# Manual Azure Container Apps Deployment Script (V2)
# Use this if the GitHub Actions workflow fails

set -e

# Configuration
RESOURCE_GROUP="rg-prompt-booster"
CONTAINER_APP_NAME="prompt-booster-production"
CONTAINER_APP_ENVIRONMENT="env-prompt-booster-production"
ACR_NAME="acrpromptboosterproduction"
IMAGE_NAME="prompt-booster"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Manual Azure Container Apps Deployment (V2)${NC}"
echo "================================================"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Azure${NC}"

# Get the latest image tag
IMAGE_TAG="${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest"
echo -e "${YELLOW}📦 Using image: $IMAGE_TAG${NC}"

# Ensure ACR admin user is enabled and get credentials
echo -e "${YELLOW}🔐 Setting up ACR authentication...${NC}"
az acr update --name $ACR_NAME --admin-enabled true > /dev/null

ACR_SERVER="${ACR_NAME}.azurecr.io"
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

if [ -z "$ACR_USERNAME" ] || [ -z "$ACR_PASSWORD" ]; then
  echo -e "${RED}❌ Failed to retrieve ACR credentials${NC}"
  exit 1
fi

echo -e "${GREEN}✅ ACR credentials retrieved successfully${NC}"

# Check if container app exists
echo -e "\n${YELLOW}🔄 Checking container app status...${NC}"

if az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
    echo -e "${GREEN}📦 Container app exists - deleting and recreating with proper ACR config...${NC}"
    
    # Delete the existing container app that has failed provisioning
    echo -e "${YELLOW}🗑️ Deleting failed container app...${NC}"
    az containerapp delete \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --yes
    
    echo -e "${GREEN}✅ Old container app deleted${NC}"
fi

# Ensure container app environment exists
echo -e "${YELLOW}🌍 Checking container app environment...${NC}"
if ! az containerapp env show --name $CONTAINER_APP_ENVIRONMENT --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
    echo -e "${YELLOW}🏗️ Creating container app environment...${NC}"
    az containerapp env create \
        --name $CONTAINER_APP_ENVIRONMENT \
        --resource-group $RESOURCE_GROUP \
        --location "Central India"
fi

echo -e "${GREEN}✅ Environment ready${NC}"

# Create the container app with proper ACR credentials
echo -e "\n${YELLOW}🚀 Creating container app with ACR credentials...${NC}"
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $CONTAINER_APP_ENVIRONMENT \
    --image $IMAGE_TAG \
    --registry-server $ACR_SERVER \
    --registry-username $ACR_USERNAME \
    --registry-password $ACR_PASSWORD \
    --min-replicas 1 \
    --max-replicas 5 \
    --cpu 0.75 \
    --memory 1.5Gi \
    --ingress external \
    --target-port 3000 \
    --transport http \
    --env-vars \
        NODE_ENV=production \
        NEXT_TELEMETRY_DISABLED=1 \
        PORT=3000

echo -e "${GREEN}✅ Container app created successfully with ACR credentials${NC}"

# Wait for deployment to complete
echo -e "\n${YELLOW}⏳ Waiting for deployment to complete...${NC}"
sleep 30

# Check deployment status
echo -e "${YELLOW}🔍 Checking deployment status...${NC}"
PROVISIONING_STATE=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.provisioningState" --output tsv)
echo -e "${BLUE}Provisioning State: $PROVISIONING_STATE${NC}"

# Get the application URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "properties.configuration.ingress.fqdn" \
    --output tsv 2>/dev/null)

if [ -n "$APP_URL" ]; then
    echo -e "\n${GREEN}🎉 Deployment completed successfully!${NC}"
    echo -e "${GREEN}🌐 Application URL: https://$APP_URL${NC}"
    
    # Test the health endpoint
    echo -e "\n${YELLOW}🩺 Testing health endpoint...${NC}"
    for i in {1..20}; do
        if curl -f -s "https://$APP_URL/api/health" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Health check passed${NC}"
            break
        fi
        echo -e "${YELLOW}⏳ Attempt $i/20: Waiting for app to be ready...${NC}"
        sleep 15
    done
    
    # Final health check
    if curl -f -s "https://$APP_URL/api/health" > /dev/null 2>&1; then
        echo -e "\n${GREEN}🎊 Application is live and healthy!${NC}"
        echo -e "${GREEN}🔗 Visit: https://$APP_URL${NC}"
    else
        echo -e "\n${YELLOW}⚠️  App deployed but health check failed. It might still be starting up.${NC}"
        echo -e "${BLUE}🔗 Check manually: https://$APP_URL${NC}"
    fi
else
    echo -e "\n${RED}❌ Could not retrieve application URL${NC}"
    echo -e "${YELLOW}💡 Check Azure portal for more details${NC}"
fi

echo -e "\n${BLUE}📋 Deployment Summary:${NC}"
echo -e "${BLUE}======================${NC}"
echo -e "Resource Group: $RESOURCE_GROUP"
echo -e "Container App: $CONTAINER_APP_NAME"
echo -e "Image: $IMAGE_TAG"
echo -e "ACR Server: $ACR_SERVER"
echo -e "Provisioning State: $PROVISIONING_STATE"
echo -e "App URL: ${APP_URL:-'Not available'}"
