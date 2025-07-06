#!/bin/bash

# Container App Status Check Script
# This script provides detailed information about the container app status

set -e

# Configuration
RESOURCE_GROUP="rg-prompt-booster"
CONTAINER_APP_NAME="prompt-booster-production"
ACR_NAME="acrpromptboosterproduction"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Container App Status Check${NC}"
echo "==============================="

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

# Check container app status
echo -e "\n${YELLOW}1. Container App Overview:${NC}"
if az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Container app exists${NC}"
    
    # Get basic info
    echo -e "\n${BLUE}📊 Basic Information:${NC}"
    az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
        --query "{name: name, location: location, provisioningState: properties.provisioningState, runningStatus: properties.runningStatus}" \
        --output table
    
    # Get current image
    echo -e "\n${BLUE}🖼️ Current Container Image:${NC}"
    CURRENT_IMAGE=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
        --query "properties.template.containers[0].image" --output tsv)
    echo "Image: $CURRENT_IMAGE"
    
    # Get registry configuration
    echo -e "\n${BLUE}📋 Registry Configuration:${NC}"
    az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
        --query "properties.template.registries" --output table
    
    # Get revision status
    echo -e "\n${BLUE}🔄 Revision Status:${NC}"
    az containerapp revision list --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
        --query "[].{Name:name, Active:properties.active, CreatedTime:properties.createdTime, TrafficWeight:properties.trafficWeight, ProvisioningState:properties.provisioningState}" \
        --output table
    
    # Get replica status
    echo -e "\n${BLUE}⚙️ Replica Status:${NC}"
    az containerapp replica list --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP \
        --query "[].{Name:name, State:properties.runningState, CreatedTime:properties.createdTime}" \
        --output table
    
    # Check for recent events/logs
    echo -e "\n${BLUE}📝 Recent Logs (last 10 lines):${NC}"
    az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --tail 10 2>/dev/null || echo "No logs available"
    
else
    echo -e "${RED}❌ Container app does not exist${NC}"
fi

# Check ACR status
echo -e "\n${YELLOW}2. ACR Status:${NC}"
if az acr show --name $ACR_NAME > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ACR exists${NC}"
    
    # Check admin user status
    ADMIN_ENABLED=$(az acr show --name $ACR_NAME --query "adminUserEnabled" --output tsv)
    if [ "$ADMIN_ENABLED" = "true" ]; then
        echo -e "${GREEN}✅ Admin user enabled${NC}"
    else
        echo -e "${RED}❌ Admin user NOT enabled${NC}"
        echo -e "${YELLOW}💡 Run: az acr update --name $ACR_NAME --admin-enabled true${NC}"
    fi
    
    # List available images
    echo -e "\n${BLUE}🖼️ Available Images in ACR:${NC}"
    az acr repository list --name $ACR_NAME --output table
    
    # Check specific image
    echo -e "\n${BLUE}🔍 Latest prompt-booster image:${NC}"
    if az acr repository show --name $ACR_NAME --image "prompt-booster:latest" > /dev/null 2>&1; then
        az acr repository show --name $ACR_NAME --image "prompt-booster:latest" \
            --query "{digest: digest, createdTime: createdTime, lastUpdateTime: lastUpdateTime}" \
            --output table
    else
        echo -e "${RED}❌ prompt-booster:latest image not found${NC}"
    fi
else
    echo -e "${RED}❌ ACR does not exist${NC}"
fi

# Check environment status
echo -e "\n${YELLOW}3. Container App Environment:${NC}"
ENVIRONMENT_NAME="env-prompt-booster"
if az containerapp env show --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Environment exists${NC}"
    az containerapp env show --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP \
        --query "{name: name, location: location, provisioningState: properties.provisioningState}" \
        --output table
else
    echo -e "${RED}❌ Environment does not exist${NC}"
fi

echo -e "\n${GREEN}🎉 Status check completed!${NC}"
