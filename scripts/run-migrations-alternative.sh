#!/bin/bash

# Alternative Database Migration Script
# This script runs database migrations using the Container App itself instead of Azure Container Instances

set -e

# Configuration
RESOURCE_GROUP="rg-prompt-booster"
CONTAINER_APP_NAME="prompt-booster-production"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️ Alternative Database Migration Runner${NC}"
echo "=========================================="

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Azure${NC}"

# Check if container app exists and is running
echo -e "${YELLOW}🔍 Checking container app status...${NC}"
if ! az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
    echo -e "${RED}❌ Container app '$CONTAINER_APP_NAME' not found${NC}"
    exit 1
fi

PROVISIONING_STATE=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.provisioningState" --output tsv)
RUNNING_STATUS=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.runningStatus" --output tsv)

echo -e "${BLUE}📊 Container App Status:${NC}"
echo -e "Provisioning State: $PROVISIONING_STATE"
echo -e "Running Status: $RUNNING_STATUS"

if [ "$PROVISIONING_STATE" != "Succeeded" ] || [ "$RUNNING_STATUS" != "Running" ]; then
    echo -e "${RED}❌ Container app is not in a running state${NC}"
    echo -e "${YELLOW}💡 Please ensure the app is deployed and healthy before running migrations${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Container app is running${NC}"

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
        exit 1
    fi
else
    echo -e "${RED}❌ package.json not found${NC}"
    exit 1
fi

# Method 1: Try using exec if supported
echo -e "\n${YELLOW}🚀 Attempting to run migrations...${NC}"
echo -e "${BLUE}Command: $MIGRATION_COMMAND${NC}"

# Get the revision name
REVISION_NAME=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.latestRevisionName" --output tsv)
echo -e "${BLUE}Using revision: $REVISION_NAME${NC}"

# Try to execute the migration command
echo -e "${YELLOW}📝 Note: This will run migrations in the existing container app${NC}"
echo -e "${YELLOW}📝 Make sure your DATABASE_URL environment variable is properly set${NC}"

read -p "Continue with migration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}ℹ️  Migration cancelled by user${NC}"
    exit 0
fi

# For Container Apps, we can't directly exec into containers like in Kubernetes
# Instead, we'll provide instructions for manual migration
echo -e "\n${YELLOW}📋 Manual Migration Instructions:${NC}"
echo -e "${BLUE}Since Azure Container Apps doesn't support direct exec, here are your options:${NC}"
echo ""
echo -e "${YELLOW}Option 1: Local Migration (Recommended)${NC}"
echo -e "1. Ensure you have the DATABASE_URL secret value"
echo -e "2. Run locally: ${YELLOW}DATABASE_URL='<your-db-url>' $MIGRATION_COMMAND${NC}"
echo ""
echo -e "${YELLOW}Option 2: Temporary Container (if Azure Container Instances is available)${NC}"
echo -e "1. Run: ${YELLOW}./scripts/run-migration-container.sh${NC}"
echo ""
echo -e "${YELLOW}Option 3: Update Container App with Migration Init${NC}"
echo -e "1. Temporarily modify Dockerfile to run migrations on startup"
echo -e "2. Deploy the updated container"
echo -e "3. Revert the Dockerfile changes and redeploy"

# Check if we have the database URL available
if [ -n "$DATABASE_URL" ]; then
    echo -e "\n${GREEN}✅ DATABASE_URL is available in environment${NC}"
    echo -e "${YELLOW}🚀 Running migration locally...${NC}"
    
    if command -v npm > /dev/null 2>&1; then
        echo -e "${BLUE}Running: $MIGRATION_COMMAND${NC}"
        eval $MIGRATION_COMMAND
        echo -e "${GREEN}✅ Migration completed successfully${NC}"
    else
        echo -e "${RED}❌ npm not found. Please run migration manually with:${NC}"
        echo -e "${YELLOW}DATABASE_URL='<your-db-url>' $MIGRATION_COMMAND${NC}"
    fi
else
    echo -e "\n${YELLOW}⚠️  DATABASE_URL not found in environment${NC}"
    echo -e "${BLUE}Please set the DATABASE_URL and run migration manually${NC}"
fi

echo -e "\n${BLUE}🔍 Migration Complete${NC}"
echo -e "${BLUE}=====================${NC}"
echo -e "If migration was successful, your database schema should now be up to date."
