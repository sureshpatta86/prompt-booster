#!/bin/bash

# Azure Container Apps Deployment Troubleshooting Script
# This script helps diagnose common deployment issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="rg-prompt-booster"
CONTAINER_APP_NAME="prompt-booster-production"
ACR_NAME="acrpromptboosterproduction"

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} Azure Container Apps Troubleshoot${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_section() {
    echo -e "${YELLOW}--- $1 ---${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

check_azure_login() {
    print_section "Checking Azure Login"
    
    if az account show > /dev/null 2>&1; then
        ACCOUNT=$(az account show --query name -o tsv)
        print_success "Logged in to Azure account: $ACCOUNT"
    else
        print_error "Not logged in to Azure. Run: az login"
        exit 1
    fi
}

check_resource_group() {
    print_section "Checking Resource Group"
    
    if az group show --name $RESOURCE_GROUP > /dev/null 2>&1; then
        print_success "Resource group '$RESOURCE_GROUP' exists"
    else
        print_error "Resource group '$RESOURCE_GROUP' not found"
        exit 1
    fi
}

check_container_registry() {
    print_section "Checking Container Registry"
    
    if az acr show --name $ACR_NAME > /dev/null 2>&1; then
        print_success "Container registry '$ACR_NAME' exists"
        
        # Check if we can login
        if az acr login --name $ACR_NAME > /dev/null 2>&1; then
            print_success "Successfully logged into container registry"
        else
            print_error "Failed to login to container registry"
        fi
    else
        print_error "Container registry '$ACR_NAME' not found"
        exit 1
    fi
}

check_container_app() {
    print_section "Checking Container App"
    
    if az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
        print_success "Container app '$CONTAINER_APP_NAME' exists"
        
        # Get app status
        STATUS=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query properties.runningStatus -o tsv)
        echo "Status: $STATUS"
        
        # Get current image
        IMAGE=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query properties.template.containers[0].image -o tsv)
        echo "Current image: $IMAGE"
        
        # Get replica count
        REPLICAS=$(az containerapp replica list --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query "length(@)" -o tsv)
        echo "Active replicas: $REPLICAS"
        
    else
        print_error "Container app '$CONTAINER_APP_NAME' not found"
        exit 1
    fi
}

check_container_app_logs() {
    print_section "Checking Container App Logs"
    
    echo "Recent logs from container app:"
    az containerapp logs show \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --tail 50 \
        --follow false || print_warning "Could not retrieve logs"
}

check_ingress() {
    print_section "Checking Ingress Configuration"
    
    FQDN=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv)
    
    if [ -n "$FQDN" ]; then
        print_success "App URL: https://$FQDN"
        
        # Test health endpoint
        print_section "Testing Health Endpoint"
        if curl -f -s "https://$FQDN/api/health" > /dev/null; then
            print_success "Health endpoint is responding"
            curl -s "https://$FQDN/api/health" | jq . || echo "Health response (not JSON)"
        else
            print_error "Health endpoint is not responding"
            
            # Try to get more info
            echo "Attempting to test connectivity..."
            curl -v "https://$FQDN/api/health" || true
        fi
    else
        print_error "No ingress FQDN found - app might not be exposed"
    fi
}

check_environment_variables() {
    print_section "Checking Environment Variables"
    
    echo "Environment variables set on container app:"
    az containerapp show \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --query properties.template.containers[0].env \
        -o table || print_warning "Could not retrieve environment variables"
}

check_revision_status() {
    print_section "Checking Revision Status"
    
    echo "Container app revisions:"
    az containerapp revision list \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "[].{Name:name,Active:properties.active,CreatedTime:properties.createdTime,TrafficWeight:properties.trafficWeight}" \
        -o table || print_warning "Could not retrieve revisions"
}

check_container_registry_images() {
    print_section "Checking Container Registry Images"
    
    echo "Recent images in registry:"
    az acr repository show-tags \
        --name $ACR_NAME \
        --repository prompt-booster \
        --top 10 \
        --orderby time_desc \
        -o table || print_warning "Could not retrieve image tags"
}

main() {
    print_header
    
    check_azure_login
    check_resource_group
    check_container_registry
    check_container_app
    check_ingress
    check_environment_variables
    check_revision_status
    check_container_registry_images
    check_container_app_logs
    
    echo
    print_success "Troubleshooting complete!"
    echo
    echo "If you're still experiencing issues, check:"
    echo "1. GitHub Actions logs for build/deployment errors"
    echo "2. Azure Portal for detailed container app insights"
    echo "3. Container app metrics and monitoring"
}

# Run the troubleshooting
main "$@"
