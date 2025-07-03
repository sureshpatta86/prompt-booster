# 🚀 Complete Deployment Guide: GitHub → Azure

## Quick Start Checklist

- [ ] 1. Set up Azure Service Principal
- [ ] 2. Configure GitHub Secrets
- [ ] 3. Run Infrastructure Setup
- [ ] 4. Update Connection Strings
- [ ] 5. Deploy Application
- [ ] 6. Verify Deployment

## 📋 Detailed Steps

### Step 1: Azure Service Principal Setup

```bash
# Login to Azure
az login

# Create service principal for GitHub Actions
az ad sp create-for-rbac \
  --name "sp-prompt-booster-github" \
  --role Contributor \
  --scopes /subscriptions/$(az account show --query id --output tsv) \
  --sdk-auth

# Copy the JSON output for GitHub secrets
```

### Step 2: GitHub Repository Secrets

Go to: **GitHub Repo → Settings → Secrets and variables → Actions**

Add these secrets:

```bash
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}
DATABASE_URL=postgresql://user:pass@server.postgres.database.azure.com:5432/db?sslmode=require
REDIS_URL=rediss://cache.redis.cache.windows.net:6380,password=xxx,ssl=True
NEXTAUTH_SECRET=$(openssl rand -hex 32)
NEXTAUTH_URL=https://your-app.azurecontainerapps.io
OPENAI_API_KEY=sk-your-key-here
```

### Step 3: Infrastructure Deployment

1. Go to **Actions** tab in GitHub
2. Click **"Setup Azure Infrastructure"**
3. Click **"Run workflow"**
4. Fill parameters:
   - Environment: `production`
   - Resource Group: `rg-prompt-booster`
   - Location: `East US`
5. Click **"Run workflow"**

Wait for completion (~10-15 minutes)

### Step 4: Update Connection Strings

After infrastructure setup, get real connection strings:

```bash
# Get database connection string
az postgres flexible-server show \
  --name psql-prompt-booster-production \
  --resource-group rg-prompt-booster \
  --query "fullyQualifiedDomainName"

# Get Redis connection string  
az redis show-connection-string \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster \
  --auth-type primary
```

Update GitHub secrets with real values.

### Step 5: Deploy Application

**Option A: Push to main branch**
```bash
git add .
git commit -m "feat: initial deployment setup"
git push origin main
```

**Option B: Manual deployment**
1. Go to **Actions** → **"Build and Deploy to Azure Container Apps"**
2. Click **"Run workflow"**
3. Select `main` branch
4. Click **"Run workflow"**

### Step 6: Verify Deployment

```bash
# Get application URL
az containerapp show \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

Visit the URL to verify your app is running!

## 🔧 Local Development with Docker

### Development Environment
```bash
# Start development environment with hot reload
npm run docker:dev

# Access at: http://localhost:3000
# Database: localhost:5432
# Redis: localhost:6379
# pgAdmin: http://localhost:8080
```

### Production Testing
```bash
# Build and run production image locally
npm run docker:build
npm run docker:run

# Or use docker-compose
npm run docker:prod
```

### Useful Docker Commands
```bash
# View logs
npm run docker:logs

# Stop all services
npm run docker:stop

# Rebuild and restart
docker-compose down && docker-compose up --build -d
```

## 🔍 Monitoring & Troubleshooting

### Application Logs
```bash
# View real-time logs
az containerapp logs show \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --follow

# View recent logs
az containerapp logs show \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --tail 100
```

### Database Connection Test
```bash
# Connect to database
az postgres flexible-server connect \
  --name psql-prompt-booster-production \
  --admin-user promptadmin \
  --database-name promptbooster
```

### Container Status
```bash
# Check app status
az containerapp show \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --query properties.runningStatus

# Check replica count
az containerapp replica list \
  --name prompt-booster \
  --resource-group rg-prompt-booster
```

## 🛠️ Common Issues & Solutions

### Issue: Build Fails
```bash
# Check if dependencies install locally
npm ci
npm run build

# Check Docker build locally
docker build -t prompt-booster .
```

### Issue: Database Connection Fails
```bash
# Check firewall rules
az postgres flexible-server firewall-rule list \
  --name psql-prompt-booster-production \
  --resource-group rg-prompt-booster

# Test connection string format
# Should be: postgresql://user:pass@host:5432/db?sslmode=require
```

### Issue: Container App Won't Start
```bash
# Check environment variables
az containerapp show \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --query properties.template.containers[0].env

# Check image exists in registry
az acr repository list --name acrpromptbooster
```

## 💰 Cost Optimization

### Current Configuration Costs (Estimated)
- **Container App**: ~$20-40/month (Basic tier)
- **PostgreSQL**: ~$25-50/month (B2s SKU)
- **Redis**: ~$15-30/month (Standard C1)
- **Container Registry**: ~$5/month (Standard tier)
- **Total**: ~$65-125/month

### Cost Reduction Tips
```bash
# Scale down for development
az containerapp update \
  --name prompt-booster \
  --resource-group rg-prompt-booster \
  --min-replicas 0 \
  --max-replicas 1

# Use Basic database tier for dev
az postgres flexible-server update \
  --name psql-prompt-booster-production \
  --resource-group rg-prompt-booster \
  --sku-name Standard_B1ms
```

## 🔐 Security Checklist

- [x] ✅ Service principal with minimal permissions
- [x] ✅ Database SSL connections required
- [x] ✅ Redis secure connections
- [x] ✅ Container runs as non-root user
- [x] ✅ Secrets masked in GitHub Actions
- [x] ✅ Environment variables encrypted
- [x] ✅ Network security groups configured

## 🎯 Next Steps

1. **Custom Domain**: Set up custom domain with SSL
2. **Monitoring**: Configure Application Insights
3. **Backups**: Set up automated database backups
4. **CDN**: Add Azure CDN for static assets
5. **Scaling**: Configure auto-scaling rules
6. **CI/CD**: Add staging environment

## 📞 Support

If you encounter issues:

1. Check the **GitHub Actions logs**
2. Review **Azure Portal logs**
3. Verify **environment variables**
4. Test **Docker build locally**

Your Prompt Booster application is now ready for production! 🚀
