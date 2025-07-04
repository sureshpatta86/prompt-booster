#!/bin/bash

# Test ACR Authentication Script
# This script verifies that ACR credentials are working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ACR_NAME="acrpromptboosterproduction"
IMAGE_NAME="prompt-booster"

echo -e "${BLUE}🔍 Testing ACR Authentication${NC}"
echo -e "${BLUE}============================${NC}"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

echo -e "\n${YELLOW}1. Testing ACR login...${NC}"
if az acr login --name $ACR_NAME; then
    echo -e "${GREEN}✅ ACR login successful${NC}"
else
    echo -e "${RED}❌ ACR login failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}2. Getting ACR credentials...${NC}"
ACR_SERVER="${ACR_NAME}.azurecr.io"
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

if [ -n "$ACR_USERNAME" ] && [ -n "$ACR_PASSWORD" ]; then
    echo -e "${GREEN}✅ ACR credentials retrieved successfully${NC}"
    echo -e "${BLUE}📊 Server: $ACR_SERVER${NC}"
    echo -e "${BLUE}📊 Username: $ACR_USERNAME${NC}"
    echo -e "${BLUE}📊 Password: [HIDDEN]${NC}"
else
    echo -e "${RED}❌ Failed to get ACR credentials${NC}"
    exit 1
fi

echo -e "\n${YELLOW}3. Testing Docker login with credentials...${NC}"
if echo "$ACR_PASSWORD" | docker login $ACR_SERVER -u $ACR_USERNAME --password-stdin; then
    echo -e "${GREEN}✅ Docker login to ACR successful${NC}"
else
    echo -e "${RED}❌ Docker login to ACR failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}4. Checking if image exists in registry...${NC}"
IMAGE_TAG="${ACR_SERVER}/${IMAGE_NAME}:latest"
if az acr repository show --name $ACR_NAME --image ${IMAGE_NAME}:latest > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Image exists in registry: $IMAGE_TAG${NC}"
else
    echo -e "${YELLOW}⚠️ Image not found in registry: $IMAGE_TAG${NC}"
    echo -e "${BLUE}💡 This is normal if you haven't pushed the image yet${NC}"
fi

echo -e "\n${YELLOW}5. Testing image pull capability...${NC}"
if docker pull $IMAGE_TAG > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Image pull successful${NC}"
    # Clean up pulled image
    docker rmi $IMAGE_TAG > /dev/null 2>&1 || true
else
    echo -e "${YELLOW}⚠️ Image pull failed (expected if image doesn't exist)${NC}"
fi

echo -e "\n${GREEN}🎉 ACR authentication test completed!${NC}"
echo -e "${BLUE}📝 Summary:${NC}"
echo -e "   • ACR Login: ✅ Working"
echo -e "   • Credentials: ✅ Retrieved"
echo -e "   • Docker Login: ✅ Working"
echo -e "   • Ready for Container Apps deployment"

echo -e "\n${YELLOW}💡 Next steps:${NC}"
echo -e "   • Push your code to trigger the GitHub Actions workflow"
echo -e "   • Or run: ./scripts/deploy-azure-manual.sh"
