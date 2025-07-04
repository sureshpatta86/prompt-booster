#!/bin/bash

# Register Azure Resource Providers Script
# This script registers the required Azure resource providers for the project

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Azure Resource Provider Registration${NC}"
echo "========================================"

# Check if logged in to Azure
if ! az account show > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Azure${NC}"

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)
SUBSCRIPTION_NAME=$(az account show --query "name" --output tsv)

echo -e "${BLUE}📋 Current Subscription:${NC}"
echo -e "ID: $SUBSCRIPTION_ID"
echo -e "Name: $SUBSCRIPTION_NAME"

# List of required resource providers
PROVIDERS=(
    "Microsoft.App"
    "Microsoft.ContainerRegistry" 
    "Microsoft.ContainerInstance"
    "Microsoft.OperationalInsights"
    "Microsoft.Storage"
)

echo -e "\n${YELLOW}🔍 Checking resource provider registration status...${NC}"

for provider in "${PROVIDERS[@]}"; do
    echo -e "\n${BLUE}Checking: $provider${NC}"
    
    # Get current registration state
    STATE=$(az provider show --namespace "$provider" --query "registrationState" --output tsv 2>/dev/null || echo "NotFound")
    
    case $STATE in
        "Registered")
            echo -e "${GREEN}✅ $provider - Already registered${NC}"
            ;;
        "Registering")
            echo -e "${YELLOW}⏳ $provider - Registration in progress${NC}"
            ;;
        "NotRegistered"|"NotFound")
            echo -e "${YELLOW}📝 $provider - Not registered, registering now...${NC}"
            if az provider register --namespace "$provider"; then
                echo -e "${GREEN}✅ $provider - Registration started${NC}"
            else
                echo -e "${RED}❌ $provider - Registration failed${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}⚠️  $provider - Unknown state: $STATE${NC}"
            ;;
    esac
done

echo -e "\n${YELLOW}⏳ Waiting for all registrations to complete...${NC}"
echo -e "${BLUE}Note: Resource provider registration can take several minutes${NC}"

# Wait for all providers to be registered
all_registered=false
max_attempts=30
attempt=0

while [ "$all_registered" = false ] && [ $attempt -lt $max_attempts ]; do
    attempt=$((attempt + 1))
    echo -e "\n${BLUE}Attempt $attempt/$max_attempts - Checking registration status...${NC}"
    
    all_registered=true
    for provider in "${PROVIDERS[@]}"; do
        STATE=$(az provider show --namespace "$provider" --query "registrationState" --output tsv 2>/dev/null || echo "NotFound")
        
        if [ "$STATE" != "Registered" ]; then
            echo -e "${YELLOW}⏳ $provider: $STATE${NC}"
            all_registered=false
        else
            echo -e "${GREEN}✅ $provider: $STATE${NC}"
        fi
    done
    
    if [ "$all_registered" = false ]; then
        echo -e "${BLUE}Waiting 30 seconds before next check...${NC}"
        sleep 30
    fi
done

if [ "$all_registered" = true ]; then
    echo -e "\n${GREEN}🎉 All resource providers are now registered!${NC}"
    echo -e "${GREEN}✅ Your subscription is ready for Azure Container Apps deployment${NC}"
else
    echo -e "\n${YELLOW}⚠️  Some resource providers are still registering${NC}"
    echo -e "${BLUE}💡 You can continue with deployment, but some features may not work until registration completes${NC}"
    echo -e "${BLUE}💡 Registration typically completes within 5-15 minutes${NC}"
fi

echo -e "\n${BLUE}📋 Final Status:${NC}"
for provider in "${PROVIDERS[@]}"; do
    STATE=$(az provider show --namespace "$provider" --query "registrationState" --output tsv 2>/dev/null || echo "NotFound")
    case $STATE in
        "Registered")
            echo -e "${GREEN}✅ $provider${NC}"
            ;;
        *)
            echo -e "${YELLOW}⏳ $provider: $STATE${NC}"
            ;;
    esac
done

echo -e "\n${BLUE}🔗 Next Steps:${NC}"
echo -e "1. Run your deployment: ./scripts/deploy-azure-fresh.sh"
echo -e "2. Or push to main branch to trigger GitHub Actions"
echo -e "3. Monitor the deployment progress"
