# GitHub Actions Setup Guide for Azure Deployment

## Prerequisites

- Azure CLI installed locally
- GitHub repository with admin access
- Azure subscription with Contributor access

## Step 1: Create Azure Service Principal

Run these commands in your terminal:

```bash
# Set variables
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SERVICE_PRINCIPAL_NAME="sp-prompt-booster-github"
RESOURCE_GROUP="rg-prompt-booster"

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name $SERVICE_PRINCIPAL_NAME \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth \
  --json-auth > azure-credentials.json

# Display the credentials (copy this JSON)
cat azure-credentials.json
```

## Step 2: Configure GitHub Repository Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these **Repository Secrets**:

### 🔐 Required Secrets

1. **AZURE_CREDENTIALS**
   ```json
   {
     "clientId": "your-client-id",
     "clientSecret": "your-client-secret", 
     "subscriptionId": "your-subscription-id",
     "tenantId": "your-tenant-id"
   }
   ```

2. **DATABASE_URL**
   ```
   postgresql://username:password@server.postgres.database.azure.com:5432/promptbooster?sslmode=require
   ```

3. **REDIS_URL**
   ```
   rediss://your-redis.redis.cache.windows.net:6380,password=your-redis-key,ssl=True
   ```

4. **NEXTAUTH_SECRET**
   ```bash
   # Generate with: openssl rand -hex 32
   your-32-character-secret-here
   ```

5. **NEXTAUTH_URL**
   ```
   https://your-app.azurecontainerapps.io
   ```

6. **OPENAI_API_KEY**
   ```
   sk-your-openai-api-key
   ```

## Step 3: Set Up Infrastructure (One-time)

1. Go to your GitHub repository
2. Click **Actions** tab
3. Find "Setup Azure Infrastructure" workflow
4. Click **Run workflow**
5. Fill in the parameters:
   - Environment: `production`
   - Resource Group: `rg-prompt-booster`
   - Location: `East US`
6. Click **Run workflow**

This will create:
- ✅ Resource Group
- ✅ Azure Container Registry
- ✅ PostgreSQL Database
- ✅ Redis Cache
- ✅ Container Apps Environment

## Step 4: Update Secrets with Real Values

After infrastructure setup:

1. **Get Database URL**:
   ```bash
   # From Azure Portal or CLI
   az postgres flexible-server show --name psql-prompt-booster-production --resource-group rg-prompt-booster
   ```

2. **Get Redis URL**:
   ```bash
   # From Azure Portal or CLI
   az redis show-connection-string --name redis-prompt-booster-production --resource-group rg-prompt-booster
   ```

3. **Update GitHub Secrets** with the real values

## Step 5: Deploy Application

Once secrets are configured:

1. **Push to main branch** or
2. **Manually trigger deployment**:
   - Go to Actions → "Build and Deploy to Azure Container Apps"
   - Click "Run workflow"

## Workflow Triggers

### 🚀 **Main Deployment** (`.github/workflows/deploy-azure.yml`)
- Triggers on push to `main` branch
- Builds Docker image
- Pushes to Azure Container Registry
- Deploys to Azure Container Apps
- Runs database migrations

### 🔍 **PR Preview** (`.github/workflows/pr-preview.yml`)
- Triggers on Pull Requests
- Runs tests, linting, type checking
- Builds Docker image (doesn't deploy)

### 🏗️ **Infrastructure Setup** (`.github/workflows/setup-infrastructure.yml`)
- Manual trigger only
- Creates Azure resources
- One-time setup per environment

## Monitoring & Troubleshooting

### Check Deployment Status
```bash
# Check container app status
az containerapp show --name prompt-booster --resource-group rg-prompt-booster

# View logs
az containerapp logs show --name prompt-booster --resource-group rg-prompt-booster
```

### Common Issues

1. **"AZURE_CREDENTIALS not found"**
   - Ensure service principal JSON is correctly formatted
   - Verify all required fields are present

2. **"Database connection failed"**
   - Check DATABASE_URL format
   - Verify firewall rules allow Azure services

3. **"Image pull failed"**
   - Ensure Container Registry credentials are correct
   - Check if image was pushed successfully

## Security Best Practices

- ✅ Service principal has minimal required permissions
- ✅ Secrets are masked in workflow logs
- ✅ Database uses SSL connections
- ✅ Redis uses secure connections
- ✅ Container apps run as non-root user

## Cost Optimization

- **Basic SKUs** used for development
- **Auto-scaling** configured (1-10 replicas)
- **Container registry** uses Standard tier
- **Database** uses B2s SKU (can scale up)

## Next Steps

1. ✅ Run infrastructure setup
2. ✅ Configure all secrets
3. ✅ Push code to trigger deployment
4. ✅ Verify application is running
5. ✅ Set up custom domain (optional)
6. ✅ Configure monitoring alerts
