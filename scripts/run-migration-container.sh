#!/bin/bash

# Run Database Migration using Azure Container Instance
# This script creates a temporary container to run database migrations

set -e

# Configuration
RESOURCE_GROUP="rg-prompt-booster"
ACR_NAME="acrpromptboosterproduction"
IMAGE_NAME="prompt-booster"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️ Database Migration Runner${NC}"
echo "============================"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Azure${NC}"

# Check if package.json has migration script
echo -e "${YELLOW}🔍 Checking for migration script...${NC}"
if [ -f "package.json" ]; then
    if grep -q '"db:migrate"' package.json; then
        echo -e "${GREEN}✅ Found db:migrate script in package.json${NC}"
        MIGRATION_COMMAND="npm run db:migrate"
    elif grep -q '"migrate"' package.json; then
        echo -e "${GREEN}✅ Found migrate script in package.json${NC}"
        MIGRATION_COMMAND="npm run migrate"
    else
        echo -e "${YELLOW}⚠️  No migration script found in package.json${NC}"
        echo -e "${BLUE}Available scripts:${NC}"
        grep -E '"[^"]+":' package.json | grep -v '^\s*//' || echo "No scripts found"
        
        echo -e "\n${YELLOW}💡 You can still run a custom command. What would you like to run?${NC}"
        read -p "Enter command (or press Enter to skip): " custom_command
        if [ -n "$custom_command" ]; then
            MIGRATION_COMMAND="$custom_command"
        else
            echo -e "${BLUE}ℹ️  No migration command specified, exiting${NC}"
            exit 0
        fi
    fi
else
    echo -e "${RED}❌ package.json not found${NC}"
    exit 1
fi

# Get DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
    echo -e "${YELLOW}📝 DATABASE_URL not set in environment${NC}"
    read -p "Enter DATABASE_URL (or press Enter to skip): " database_url
    if [ -z "$database_url" ]; then
        echo -e "${RED}❌ DATABASE_URL is required for migrations${NC}"
        exit 1
    fi
    DATABASE_URL="$database_url"
fi

echo -e "${GREEN}✅ DATABASE_URL configured${NC}"

# Get ACR credentials
echo -e "${YELLOW}🔐 Getting ACR credentials...${NC}"
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

if [ -z "$ACR_USERNAME" ] || [ -z "$ACR_PASSWORD" ]; then
    echo -e "${RED}❌ Failed to retrieve ACR credentials${NC}"
    exit 1
fi

echo -e "${GREEN}✅ ACR credentials retrieved${NC}"

# Create container name
CONTAINER_NAME="migration-job-$(date +%s)"
IMAGE_TAG="${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest"

echo -e "\n${YELLOW}🚀 Creating migration container...${NC}"
echo -e "${BLUE}Container: $CONTAINER_NAME${NC}"
echo -e "${BLUE}Image: $IMAGE_TAG${NC}"
echo -e "${BLUE}Command: $MIGRATION_COMMAND${NC}"

# Create the container
if az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --image $IMAGE_TAG \
    --registry-login-server ${ACR_NAME}.azurecr.io \
    --registry-username $ACR_USERNAME \
    --registry-password $ACR_PASSWORD \
    --command-line "$MIGRATION_COMMAND" \
    --environment-variables \
        DATABASE_URL="$DATABASE_URL" \
        NODE_ENV=production \
    --restart-policy Never; then
    
    echo -e "${GREEN}✅ Migration container created successfully${NC}"
    
    # Wait for container to complete
    echo -e "${YELLOW}⏳ Waiting for migration to complete...${NC}"
    
    # Monitor the container
    for i in {1..30}; do
        STATE=$(az container show --name $CONTAINER_NAME --resource-group $RESOURCE_GROUP --query "containers[0].instanceView.currentState.state" --output tsv 2>/dev/null || echo "Unknown")
        
        case $STATE in
            "Running")
                echo -e "${BLUE}⏳ Migration running... (attempt $i/30)${NC}"
                sleep 10
                ;;
            "Terminated")
                EXIT_CODE=$(az container show --name $CONTAINER_NAME --resource-group $RESOURCE_GROUP --query "containers[0].instanceView.currentState.exitCode" --output tsv 2>/dev/null || echo "0")
                if [ "$EXIT_CODE" = "0" ]; then
                    echo -e "${GREEN}✅ Migration completed successfully${NC}"
                else
                    echo -e "${RED}❌ Migration failed with exit code: $EXIT_CODE${NC}"
                fi
                break
                ;;
            "Waiting"|"Pending")
                echo -e "${YELLOW}⏳ Container starting... (attempt $i/30)${NC}"
                sleep 10
                ;;
            *)
                echo -e "${YELLOW}⏳ Container state: $STATE (attempt $i/30)${NC}"
                sleep 10
                ;;
        esac
    done
    
    # Show logs
    echo -e "\n${BLUE}📝 Migration logs:${NC}"
    az container logs show --name $CONTAINER_NAME --resource-group $RESOURCE_GROUP || echo "No logs available"
    
    # Cleanup
    echo -e "\n${YELLOW}🧹 Cleaning up migration container...${NC}"
    az container delete --name $CONTAINER_NAME --resource-group $RESOURCE_GROUP --yes
    echo -e "${GREEN}✅ Cleanup completed${NC}"
    
else
    echo -e "${RED}❌ Failed to create migration container${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Migration process completed!${NC}"
