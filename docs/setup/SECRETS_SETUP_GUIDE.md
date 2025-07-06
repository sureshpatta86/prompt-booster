# 🔐 GitHub Secrets Configuration Guide

## Step 1: Create Azure Service Principal

First, create a service principal that GitHub Actions will use to deploy to Azure:

```bash
# Login to Azure CLI
az login

# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# Create service principal with proper permissions
az ad sp create-for-rbac \
  --name "sp-prompt-booster-github" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --json-auth
```

**Copy the entire JSON output** - you'll need it for the `AZURE_CREDENTIALS` secret.

## Step 2: Configure GitHub Repository Secrets

Go to your GitHub repository:
1. Click **Settings** tab
2. Click **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these **6 required secrets**:

### 🔑 1. AZURE_CREDENTIALS
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "your-client-secret-here",
  "subscriptionId": "12345678-1234-1234-1234-123456789012",
  "tenantId": "12345678-1234-1234-1234-123456789012"
}
```
*Use the JSON output from the service principal creation*

### 🗄️ 2. DATABASE_URL
```
postgresql://promptadmin:YOUR_PASSWORD@psql-prompt-booster-production.postgres.database.azure.com:5432/promptbooster?sslmode=require
```
*Replace with your actual database credentials after infrastructure setup*

### 🚀 3. REDIS_URL  
```
rediss://redis-prompt-booster-production.redis.cache.windows.net:6380,password=YOUR_REDIS_KEY,ssl=True
```
*Replace with your actual Redis credentials after infrastructure setup*

### 🔐 4. NEXTAUTH_SECRET
```bash
# Generate a secure 32-character secret
openssl rand -hex 32
```
*Use the generated value*

### 🌐 5. NEXTAUTH_URL
```
https://prompt-booster.azurecontainerapps.io
```
*This will be your app URL after deployment*

### 🤖 6. OPENAI_API_KEY
```
sk-your-openai-api-key-here
```
*Your OpenAI API key for prompt analysis features*

## Step 3: Temporary Secrets for Initial Setup

For the initial infrastructure setup, you can use placeholder values:

```bash
# Temporary DATABASE_URL (will be replaced after infrastructure setup)
DATABASE_URL="postgresql://temp:temp@temp:5432/temp"

# Temporary REDIS_URL (will be replaced after infrastructure setup)  
REDIS_URL="redis://temp:6379"

# Generate NEXTAUTH_SECRET
NEXTAUTH_SECRET=$(openssl rand -hex 32)

# Temporary NEXTAUTH_URL (will be replaced after deployment)
NEXTAUTH_URL="https://temp.azurecontainerapps.io"
```

## Step 4: Run Infrastructure Setup

After adding the secrets:

1. Go to **Actions** tab in your GitHub repository
2. Find **"Setup Azure Infrastructure"** workflow
3. Click **"Run workflow"**
4. Fill in the parameters:
   - **Environment**: `production`
   - **Resource Group**: `rg-prompt-booster`
   - **Location**: `East US`
5. Click **"Run workflow"**

Wait for the workflow to complete (~10-15 minutes).

## Step 5: Get Real Connection Strings

After infrastructure setup, get the actual connection strings:

### Get Database URL
```bash
# Get database server details
az postgres flexible-server show \
  --name psql-prompt-booster-production \
  --resource-group rg-prompt-booster

# Format: postgresql://USERNAME:PASSWORD@SERVER:5432/DATABASE?sslmode=require
# Example: postgresql://promptadmin:SecurePass123@psql-prompt-booster-production.postgres.database.azure.com:5432/promptbooster?sslmode=require
```

### Get Redis URL
```bash
# Get Redis access key
az redis list-keys \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster

# Get Redis hostname
az redis show \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster \
  --query "hostName" --output tsv

# Format: rediss://HOSTNAME:6380,password=PRIMARY_KEY,ssl=True
# Example: rediss://redis-prompt-booster-production.redis.cache.windows.net:6380,password=abc123xyz,ssl=True
```

## Step 6: Update GitHub Secrets

Update these secrets with the real values:

1. **DATABASE_URL** - Use the real PostgreSQL connection string
2. **REDIS_URL** - Use the real Redis connection string
3. **NEXTAUTH_URL** - Will be updated after first deployment

## Step 7: Deploy Application

Now you can deploy:

**Option A: Push to main branch**
```bash
git add .
git commit -m "feat: ready for deployment"
git push origin main
```

**Option B: Manual deployment**
1. Go to **Actions** → **"Build and Deploy to Azure Container Apps"**
2. Click **"Run workflow"**
3. Select `main` branch
4. Click **"Run workflow"**

## Step 8: Get Final App URL

After successful deployment:

```bash
# Get your app URL
az containerapp show \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

Update the **NEXTAUTH_URL** secret with this URL.

## 🔒 Security Best Practices

### ✅ Service Principal Permissions
- **Minimum required**: Contributor role on subscription
- **Scope**: Limited to your subscription only
- **Rotation**: Rotate credentials every 90 days

### ✅ Secret Management
- **Never commit secrets** to code
- **Use environment-specific** secrets for staging/production
- **Rotate secrets regularly**
- **Monitor secret usage** in GitHub Actions logs

### ✅ Database Security
- **SSL required** for all connections
- **Firewall rules** restrict access to Azure services only
- **Strong passwords** (minimum 12 characters)
- **Regular backups** enabled

## 🚨 Common Issues & Solutions

### Issue: "AZURE_CREDENTIALS invalid"
```bash
# Verify service principal exists
az ad sp list --display-name "sp-prompt-booster-github"

# Verify permissions
az role assignment list --assignee YOUR_CLIENT_ID
```

### Issue: "Database connection failed"
```bash
# Test connection string format
# Should include: ?sslmode=require
postgresql://user:pass@host.postgres.database.azure.com:5432/db?sslmode=require

# Check firewall rules
az postgres flexible-server firewall-rule list \
  --name psql-prompt-booster-production \
  --resource-group rg-prompt-booster
```

### Issue: "Redis connection failed"
```bash
# Verify Redis is running
az redis show \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster \
  --query "provisioningState"

# Check access keys
az redis list-keys \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster
```

## 📋 Secrets Checklist

Before deploying, verify all secrets are set:

- [ ] ✅ **AZURE_CREDENTIALS** - Valid service principal JSON
- [ ] ✅ **DATABASE_URL** - PostgreSQL connection string with SSL
- [ ] ✅ **REDIS_URL** - Redis connection string with SSL
- [ ] ✅ **NEXTAUTH_SECRET** - 32-character random string
- [ ] ✅ **NEXTAUTH_URL** - Your app domain (after deployment)
- [ ] ✅ **OPENAI_API_KEY** - Valid OpenAI API key

## 🎯 Quick Setup Script

Save this as `scripts/setup/setup-secrets.sh`:

```bash
#!/bin/bash
echo "🔐 GitHub Secrets Setup Helper"
echo "================================"

echo "1. NEXTAUTH_SECRET (generated):"
openssl rand -hex 32

echo ""
echo "2. Copy this service principal command:"
echo "az ad sp create-for-rbac --name 'sp-prompt-booster-github' --role 'Contributor' --scopes '/subscriptions/\$(az account show --query id --output tsv)' --json-auth"

echo ""
echo "3. After infrastructure setup, get connection strings:"
echo "# Database URL:"
echo "az postgres flexible-server show --name psql-prompt-booster-production --resource-group rg-prompt-booster"
echo ""
echo "# Redis URL:"
echo "az redis list-keys --name redis-prompt-booster-production --resource-group rg-prompt-booster"

echo ""
echo "4. Don't forget to add your OPENAI_API_KEY!"
```

Run with: `chmod +x scripts/setup/setup-secrets.sh && ./scripts/setup/setup-secrets.sh`

Your secrets are now ready for deployment! 🚀
