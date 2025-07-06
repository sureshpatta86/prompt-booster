# Azure Container Apps Deployment Fix Guide

## Issue Summary

The original deployment error was caused by incorrect Azure CLI syntax in the GitHub Actions workflow. The error message:

```
unrecognized arguments: --target-port 3000 --ingress external
```

This occurred because the `az containerapp update` command was using outdated parameter formats.

## What Was Fixed

### 1. **Azure CLI Command Syntax**

**Before (Incorrect):**
```bash
az containerapp update \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --target-port 3000 \
  --ingress external
```

**After (Correct):**
```bash
az containerapp update \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --image $IMAGE_TAG \
  --env-vars NODE_ENV=production ...

# Ingress handled separately if needed
az containerapp ingress enable \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --type external \
  --target-port 3000
```

### 2. **Environment Variables Syntax**

**Before:**
```bash
--set-env-vars \
  NODE_ENV=production \
  PORT=3000
```

**After:**
```bash
--env-vars \
  NODE_ENV=production \
  PORT=3000
```

### 3. **Docker Image Optimizations**

- Added health check endpoint at `/api/health`
- Optimized Dockerfile for production
- Added proper user permissions and security
- Included curl for health checks

### 4. **Health Check Implementation**

Created a robust health check endpoint that returns:

```json
{
  "status": "healthy",
  "timestamp": "2025-07-03T19:32:43.668Z",
  "uptime": 45.360083854,
  "environment": "production"
}
```

### 5. **Deployment Validation**

Added automatic health check validation after deployment:

```bash
# Wait for app to be ready
for i in {1..30}; do
  if curl -f -s "https://$APP_URL/api/health" > /dev/null; then
    echo "✅ Application health check passed"
    break
  fi
  sleep 10
done
```

## Files Modified

1. **`.github/workflows/deploy-azure.yml`**
   - Fixed Azure CLI syntax
   - Added deployment validation
   - Improved error handling

2. **`Dockerfile`**
   - Added health check support
   - Optimized for production
   - Added security improvements

3. **`app/api/health/route.ts`**
   - Created health check endpoint
   - Added comprehensive health information

4. **`scripts/troubleshoot-deployment.sh`**
   - New troubleshooting script
   - Comprehensive deployment diagnostics

## Testing the Fix

### Local Testing

1. **Test Docker Build:**
   ```bash
   docker build -t prompt-booster-test .
   docker run -d -p 3000:3000 prompt-booster-test
   curl http://localhost:3000/api/health
   ```

2. **Test Health Endpoint:**
   ```bash
   curl -f http://localhost:3000/api/health
   ```

### Azure Deployment Testing

1. **Run Troubleshooting Script:**
   ```bash
   ./scripts/troubleshoot-deployment.sh
   ```

2. **Manual Azure CLI Test:**
   ```bash
   az containerapp update \
     --name prompt-booster-production \
     --resource-group rg-prompt-booster \
     --image acrpromptboosterproduction.azurecr.io/prompt-booster:latest
   ```

## Common Issues and Solutions

### Issue 1: "Container app not found"
**Solution:** Ensure the container app was created during infrastructure setup.

### Issue 2: "Image not found"
**Solution:** Check that the container registry and image exist:
```bash
az acr repository list --name acrpromptboosterproduction
```

### Issue 3: "Health check fails"
**Solution:** Check container logs:
```bash
az containerapp logs show --name prompt-booster-production --resource-group rg-prompt-booster --tail 50
```

### Issue 4: "Ingress not working"
**Solution:** Verify ingress configuration:
```bash
az containerapp show --name prompt-booster-production --resource-group rg-prompt-booster --query properties.configuration.ingress
```

## Best Practices Implemented

1. **Health Checks:** Always include health endpoints for container orchestration
2. **Validation:** Validate deployments automatically in CI/CD
3. **Monitoring:** Include comprehensive logging and monitoring
4. **Security:** Use non-root users and minimal permissions
5. **Optimization:** Multi-stage Docker builds for smaller images

## Next Steps

1. **Deploy:** Push the updated code to trigger the GitHub Actions workflow
2. **Monitor:** Watch the deployment logs for successful completion
3. **Validate:** Use the troubleshooting script to verify everything works
4. **Scale:** Adjust resource limits based on actual usage

## Rollback Plan

If issues persist:

1. **Immediate:** Revert to previous working container image
2. **Debug:** Use troubleshooting script to identify issues
3. **Fix:** Apply targeted fixes based on diagnostics
4. **Redeploy:** Test thoroughly before redeploying

## Support Resources

- **Troubleshooting Script:** `./scripts/troubleshoot-deployment.sh`
- **Azure CLI Docs:** [Container Apps CLI Reference](https://docs.microsoft.com/en-us/cli/azure/containerapp)
- **GitHub Actions Logs:** Check workflow run details for specific errors
