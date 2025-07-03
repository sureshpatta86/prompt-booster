# 🚀 Pre-Deployment Checklist

## Before Running Deployment

### ✅ **Infrastructure Requirements**
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] GitHub CLI installed and authenticated (`gh auth login`)
- [ ] Infrastructure workflow has been run successfully
- [ ] All Azure resources created (ACR, PostgreSQL, Redis, Container Apps Environment)

### ✅ **GitHub Secrets Setup**
- [ ] `AZURE_CREDENTIALS` - Azure service principal JSON
- [ ] `DATABASE_URL` - PostgreSQL connection string with real password
- [ ] `REDIS_URL` - Redis connection string with real key
- [ ] `NEXTAUTH_SECRET` - Generated with `openssl rand -hex 32`
- [ ] `NEXTAUTH_URL` - Your app URL (can be updated after first deployment)
- [ ] `OPENAI_API_KEY` - Your OpenAI API key

### ✅ **Code Quality**
- [ ] Tests passing (`npm run test`)
- [ ] Linting passing (`npm run lint`)
- [ ] Type checking passing (`npm run type-check`)
- [ ] Build successful (`npm run build`)

### ✅ **Dependencies**
- [ ] `package-lock.json` is in sync with `package.json`
- [ ] All required dependencies installed
- [ ] No critical security vulnerabilities

## Quick Commands

### Get Connection Strings
```bash
./get-connection-strings.sh
```

### Setup GitHub Secrets
```bash
./setup-secrets.sh
```

### Test Locally
```bash
npm install
npm run build
npm run test
npm run lint
npm run type-check
```

### Deploy
```bash
git push origin main
# OR manually trigger deployment workflow in GitHub Actions
```

## Post-Deployment

### ✅ **Verification**
- [ ] Application is accessible at the deployed URL
- [ ] Database migrations ran successfully
- [ ] Redis cache is working
- [ ] Authentication (NextAuth) is working
- [ ] OpenAI API integration is working

### ✅ **Update Secrets**
- [ ] Update `NEXTAUTH_URL` with the actual deployed URL
- [ ] Test the updated authentication flow

## Troubleshooting

### Common Issues

1. **npm ci fails**: Run `rm package-lock.json && npm install` to regenerate lockfile
2. **Azure resources not found**: Check resource names match between workflows
3. **Container app fails to start**: Check environment variables and secrets
4. **Database connection fails**: Verify DATABASE_URL format and password
5. **Redis connection fails**: Verify REDIS_URL format and access key

### Useful Commands

```bash
# Check deployment status
az containerapp show --name prompt-booster-production --resource-group rg-prompt-booster

# View app logs
az containerapp logs show --name prompt-booster-production --resource-group rg-prompt-booster

# Test database connection
psql "postgresql://promptadmin:PASSWORD@psql-prompt-booster-production.postgres.database.azure.com:5432/promptbooster?sslmode=require"

# Check GitHub secrets
gh secret list
```

## Emergency Rollback

If deployment fails:

1. Check GitHub Actions logs for error details
2. Fix the issue in code
3. Push fix to main branch
4. Or manually trigger deployment workflow with working commit

## Support

- 📖 [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- 📖 [GitHub Actions Documentation](https://docs.github.com/en/actions)
- 📖 [Next.js Deployment Documentation](https://nextjs.org/docs/deployment)
