#!/bin/bash

# 🔗 Get Real Azure Connection Strings
# Run this script to get the actual connection strings for your GitHub secrets

echo "🔗 Getting Real Azure Connection Strings"
echo "========================================"
echo ""

# Set variables
RESOURCE_GROUP="rg-prompt-booster"
DB_SERVER_NAME="psql-prompt-booster-production"
REDIS_NAME="redis-prompt-booster-production"

echo "🗄️ Getting PostgreSQL Database Connection String..."
echo "======================================================"

# Get database connection details
DB_HOST=$(az postgres flexible-server show \
  --name $DB_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "fullyQualifiedDomainName" \
  --output tsv)

echo "Database Host: $DB_HOST"
echo ""
echo "⚠️  You'll need the database password that was generated during creation."
echo "   Check the GitHub Actions log from the infrastructure setup to find it."
echo ""
echo "📝 DATABASE_URL format:"
echo "postgresql://promptadmin:YOUR_PASSWORD@$DB_HOST:5432/promptbooster?sslmode=require"
echo ""

echo "🚀 Getting Redis Cache Connection String..."
echo "============================================="

# Get Redis connection details
REDIS_HOST=$(az redis show \
  --name $REDIS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "hostName" \
  --output tsv)

REDIS_PRIMARY_KEY=$(az redis list-keys \
  --name $REDIS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "primaryKey" \
  --output tsv)

echo "Redis Host: $REDIS_HOST"
echo "Redis Primary Key: $REDIS_PRIMARY_KEY"
echo ""
echo "📝 REDIS_URL (copy this exact value):"
echo "rediss://$REDIS_HOST:6380,password=$REDIS_PRIMARY_KEY,ssl=True"
echo ""

echo "📦 Getting Container Registry Details..."
echo "========================================"

ACR_NAME="acrpromptboosterproduction"
ACR_LOGIN_SERVER=$(az acr show \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "loginServer" \
  --output tsv)

echo "Container Registry: $ACR_LOGIN_SERVER"
echo ""

echo "🌐 Getting Container Apps Environment..."
echo "========================================"

CONTAINER_ENV="env-prompt-booster-production"
echo "Container Apps Environment: $CONTAINER_ENV"
echo ""

echo "✅ Infrastructure Summary"
echo "========================"
echo "📦 Container Registry: $ACR_LOGIN_SERVER"
echo "🗄️ Database Server: $DB_HOST"
echo "🚀 Redis Cache: $REDIS_HOST"
echo "🌐 Container Environment: $CONTAINER_ENV"
echo ""

echo "🔄 Next Steps:"
echo "=============="
echo "1. Update GitHub repository secrets:"
echo "   - DATABASE_URL: postgresql://promptadmin:YOUR_PASSWORD@$DB_HOST:5432/promptbooster?sslmode=require"
echo "   - REDIS_URL: rediss://$REDIS_HOST:6380,password=$REDIS_PRIMARY_KEY,ssl=True"
echo ""
echo "2. Deploy your application by pushing to main branch or running deployment workflow"
echo ""
echo "3. After deployment, update NEXTAUTH_URL with your app URL"
