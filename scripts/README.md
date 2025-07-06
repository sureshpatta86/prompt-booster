# Scripts Directory

This directory contains all automation scripts organized by category.

## 📁 Directory Structure

### 🛠️ [Setup Scripts](./setup/)
Scripts for initial project setup and configuration:
- [`setup-secrets.sh`](./setup/setup-secrets.sh) - Configure environment variables and secrets
- [`setup-github.sh`](./setup/setup-github.sh) - Set up GitHub repository and actions
- [`get-connection-strings.sh`](./setup/get-connection-strings.sh) - Retrieve database connection strings

### 🚀 [Deployment Scripts](./deployment/)
Scripts for deploying to Azure and managing deployments:
- [`deploy-azure-fresh.sh`](./deployment/deploy-azure-fresh.sh) - Fresh Azure deployment
- [`deploy-azure-manual.sh`](./deployment/deploy-azure-manual.sh) - Manual Azure deployment
- [`deploy-azure-manual-fixed.sh`](./deployment/deploy-azure-manual-fixed.sh) - Fixed manual deployment
- [`register-azure-providers.sh`](./deployment/register-azure-providers.sh) - Register Azure resource providers
- [`troubleshoot-deployment.sh`](./deployment/troubleshoot-deployment.sh) - Deployment troubleshooting

### 🗄️ [Database Scripts](./database/)
Scripts for database operations and migrations:
- [`run-migration-container.sh`](./database/run-migration-container.sh) - Run migrations in container
- [`run-migrations-alternative.sh`](./database/run-migrations-alternative.sh) - Alternative migration approach

### 🧪 [Testing Scripts](./testing/)
Scripts for testing and monitoring:
- [`test-local-deployment.sh`](./testing/test-local-deployment.sh) - Test local deployment
- [`test-acr-auth.sh`](./testing/test-acr-auth.sh) - Test Azure Container Registry authentication
- [`check-container-status.sh`](./testing/check-container-status.sh) - Monitor container status

## 🚀 Quick Start

### First Time Setup
```bash
# Set up environment and secrets
./scripts/setup/setup-secrets.sh

# Set up GitHub repository
./scripts/setup/setup-github.sh
```

### Deployment
```bash
# Fresh Azure deployment
./scripts/deployment/deploy-azure-fresh.sh

# Or manual deployment
./scripts/deployment/deploy-azure-manual-fixed.sh
```

### Database Operations
```bash
# Run database migrations
./scripts/database/run-migration-container.sh
```

### Testing
```bash
# Test local deployment
./scripts/testing/test-local-deployment.sh

# Check container status
./scripts/testing/check-container-status.sh
```

## 📝 Usage Notes

- **Make scripts executable**: `chmod +x scripts/**/*.sh`
- **Run from project root**: All scripts should be executed from the project root directory
- **Check dependencies**: Some scripts require Azure CLI, Docker, or other tools
- **Environment variables**: Ensure proper environment setup before running deployment scripts

## 🔧 Script Categories

| Category | Purpose | When to Use |
|----------|---------|-------------|
| **Setup** | Initial configuration | First time project setup |
| **Deployment** | Production deployment | When deploying to Azure |
| **Database** | Database operations | Managing database schema |
| **Testing** | Testing and monitoring | Validating deployments |

---

For detailed documentation on each script, see the individual script files or the [docs](../docs/) directory.
