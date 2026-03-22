#!/bin/bash

# 🔐 GitHub Secrets Setup Helper Script
# This script helps you generate and prepare the secrets needed for deployment

echo "🔐 GitHub Secrets Setup Helper"
echo "================================"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   brew install azure-cli  # macOS"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure first:"
    echo "   az login"
    exit 1
fi

echo "✅ Azure CLI is ready!"
echo ""

# Generate NEXTAUTH_SECRET
echo "🔑 1. NEXTAUTH_SECRET (copy this value):"
echo "================================"
NEXTAUTH_SECRET=$(openssl rand -hex 32)
echo "$NEXTAUTH_SECRET"
echo ""

# Get subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)

echo "📋 2. Azure Subscription Info:"
echo "================================"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Subscription Name: $SUBSCRIPTION_NAME"
echo ""

# Service Principal creation command
echo "🔐 3. Create Service Principal (run this command):"
echo "================================"
SP_COMMAND="az ad sp create-for-rbac --name 'sp-prompt-booster-github' --role 'Contributor' --scopes '/subscriptions/$SUBSCRIPTION_ID' --json-auth"
echo "$SP_COMMAND"
echo ""
echo "💡 Copy the entire JSON output for AZURE_CREDENTIALS secret"
echo ""

# Ask if user wants to create service principal now
read -p "🤔 Do you want to create the service principal now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
echo "📝 4. Initial Placeholder Secrets:"
echo "================================"
echo "Use these values initially, then update after infrastructure setup:"
echo ""
echo "DATABASE_URL:"
echo "\${DATABASE_URL}"
echo ""
echo "REDIS_URL:"
echo "\${REDIS_URL}"
echo ""
echo "NEXTAUTH_URL:"
echo "\${NEXTAUTH_URL}"
echo ""
echo "OPENAI_API_KEY:"
echo "\${OPENAI_API_KEY}"
echo ""

# Instructions for getting real values
echo "NEXTAUTH_URL:"
echo "https://temp.azurecontainerapps.io"
echo ""
echo "OPENAI_API_KEY:"
echo "sk-your-openai-api-key-here"
echo ""

# Instructions for getting real values
echo "🔄 5. After Infrastructure Setup:"
echo "================================"
echo "Run these commands to get real connection strings:"
echo ""
echo "# Get Database URL:"
echo "az postgres flexible-server show --name psql-prompt-booster-production --resource-group rg-prompt-booster --query 'fullyQualifiedDomainName' --output tsv"
echo ""
echo "# Get Redis Key:"
echo "az redis list-keys --name redis-prompt-booster-production --resource-group rg-prompt-booster --query 'primaryKey' --output tsv"
echo ""
echo "# Get Redis Hostname:"
echo "az redis show --name redis-prompt-booster-production --resource-group rg-prompt-booster --query 'hostName' --output tsv"
echo ""

# GitHub setup instructions
echo "📱 6. GitHub Repository Setup:"
echo "================================"
echo "1. Go to: https://github.com/YOUR_USERNAME/prompt-booster/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Add these 6 secrets:"
echo "   - AZURE_CREDENTIALS (JSON from step 3)"
echo "   - DATABASE_URL (placeholder, then real value)"
echo "   - REDIS_URL (placeholder, then real value)" 
echo "   - NEXTAUTH_SECRET (from step 1)"
echo "   - NEXTAUTH_URL (placeholder, then real app URL)"
echo "   - OPENAI_API_KEY (your OpenAI key)"
echo ""

# Next steps
echo "🚀 7. Deployment Steps:"
echo "================================"
echo "1. ✅ Add all secrets to GitHub"
echo "2. ✅ Run 'Setup Azure Infrastructure' workflow"
echo "3. ✅ Update DATABASE_URL and REDIS_URL with real values"
echo "4. ✅ Run 'Build and Deploy to Azure Container Apps' workflow"
echo "5. ✅ Update NEXTAUTH_URL with deployed app URL"
echo ""

echo "🎉 Setup complete! Check docs/setup/SECRETS_SETUP_GUIDE.md for detailed instructions."
