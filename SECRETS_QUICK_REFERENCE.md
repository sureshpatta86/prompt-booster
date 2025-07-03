# 🎯 Quick Reference: GitHub Secrets

## Required Secrets (6 total)

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CREDENTIALS` | Service Principal JSON | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |
| `DATABASE_URL` | PostgreSQL Connection | `postgresql://user:pass@host.postgres.database.azure.com:5432/db?sslmode=require` |
| `REDIS_URL` | Redis Connection | `rediss://host.redis.cache.windows.net:6380,password=key,ssl=True` |
| `NEXTAUTH_SECRET` | Auth Secret (32 chars) | `a1b2c3d4e5f6...` (generated with `openssl rand -hex 32`) |
| `NEXTAUTH_URL` | App URL | `https://prompt-booster.azurecontainerapps.io` |
| `OPENAI_API_KEY` | OpenAI API Key | `sk-proj-...` |

## 🚀 Quick Setup Commands

```bash
# 1. Generate NEXTAUTH_SECRET
openssl rand -hex 32

# 2. Create Azure Service Principal
az ad sp create-for-rbac \
  --name "sp-prompt-booster-github" \
  --role "Contributor" \
  --scopes "/subscriptions/$(az account show --query id --output tsv)" \
  --json-auth

# 3. Run the setup helper script
./setup-secrets.sh
```

## 📱 GitHub Setup Steps

1. **Go to Repository Settings**
   ```
   https://github.com/YOUR_USERNAME/prompt-booster/settings/secrets/actions
   ```

2. **Click "New repository secret"**

3. **Add each secret** from the table above

## 🔄 Update Secrets After Infrastructure Setup

After running the "Setup Azure Infrastructure" workflow:

```bash
# Get real Database URL components
az postgres flexible-server show \
  --name psql-prompt-booster-production \
  --resource-group rg-prompt-booster

# Get Redis connection details  
az redis list-keys \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster

az redis show \
  --name redis-prompt-booster-production \
  --resource-group rg-prompt-booster \
  --query "hostName"
```

## ✅ Deployment Checklist

- [ ] All 6 secrets added to GitHub
- [ ] AZURE_CREDENTIALS tested (service principal works)
- [ ] DATABASE_URL includes `?sslmode=require`
- [ ] REDIS_URL includes `,ssl=True`
- [ ] NEXTAUTH_SECRET is 32+ characters
- [ ] OPENAI_API_KEY is valid

## 🆘 Need Help?

Run the interactive setup script:
```bash
./setup-secrets.sh
```

Or check the detailed guide:
```bash
cat SECRETS_SETUP_GUIDE.md
```
