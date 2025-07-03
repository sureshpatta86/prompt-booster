# Azure Deployment - Simplified Approach

## Option 1: Minimal Database Setup
```bash
# Use Azure Container Apps with managed PostgreSQL
DATABASE_URL="postgresql://user:pass@your-azure-db.postgres.database.azure.com:5432/promptbooster"
```

## Option 2: Start with SQLite (Easy Migration Later)
```bash
# For immediate deployment, use SQLite
DATABASE_URL="file:./database.db"
```

## Option 3: Serverless Database
```bash
# Use Azure Cosmos DB for automatic scaling
DATABASE_URL="your-cosmos-db-connection-string"
```

## Quick Deploy Commands
```bash
# Build and deploy to Azure Container Apps
az containerapp up --name prompt-booster --source .
```
