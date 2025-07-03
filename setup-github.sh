#!/bin/bash

# 🚀 Quick GitHub Repository Setup Script
# Run this script after creating your GitHub repository

echo "🚀 Setting up GitHub repository for Prompt Booster..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the prompt-booster directory"
    exit 1
fi

# Prompt for GitHub username
echo "📝 Please enter your GitHub username:"
read -r GITHUB_USERNAME

# Prompt for repository visibility
echo "🔒 Repository visibility:"
echo "1) Public"
echo "2) Private"
echo "Enter choice (1 or 2):"
read -r REPO_VISIBILITY

# Set repository URL
REPO_URL="https://github.com/${GITHUB_USERNAME}/prompt-booster.git"

echo "🔗 Repository URL: ${REPO_URL}"
echo ""
echo "⚠️  IMPORTANT: Before running the next commands, please:"
echo "1. Go to https://github.com/new"
echo "2. Create a repository named 'prompt-booster'"
echo "3. Choose the visibility you selected above"
echo "4. DON'T initialize with README, .gitignore, or license"
echo ""
echo "✅ After creating the repository, run these commands:"
echo ""
echo "git remote add origin ${REPO_URL}"
echo "git branch -M main"
echo "git push -u origin main"
echo ""
echo "🎉 Your Prompt Booster project will then be live on GitHub!"

# Optional: Open GitHub in browser
echo ""
echo "🌐 Open GitHub repository creation page? (y/n)"
read -r OPEN_BROWSER

if [ "$OPEN_BROWSER" = "y" ] || [ "$OPEN_BROWSER" = "Y" ]; then
    open "https://github.com/new"
fi
