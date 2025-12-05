#!/bin/bash

# IPTV Web Player - Quick Deploy Script
# This script initializes a git repository and deploys to GitHub Pages

set -e

echo "🚀 IPTV Web Player - Deployment Script"
echo "======================================"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git branch -M main
else
    echo "✅ Git repository already initialized"
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Please copy .env.example to .env and configure your credentials:"
    echo "  cp .env.example .env"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to abort..."
fi

# Add all files
echo "📝 Adding files to git..."
git add .

# Commit
read -p "Enter commit message (or press Enter for default): " commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="Initial deployment"
fi

git commit -m "$commit_msg" || echo "No changes to commit"

# Ask for remote URL
if ! git remote get-url origin > /dev/null 2>&1; then
    echo ""
    echo "🔗 GitHub Repository Setup"
    echo "Please create a new repository on GitHub first: https://github.com/new"
    echo ""
    read -p "Enter your GitHub repository URL (e.g., https://github.com/username/iptv-web-player.git): " repo_url
    
    if [ -z "$repo_url" ]; then
        echo "❌ Repository URL is required"
        exit 1
    fi
    
    git remote add origin "$repo_url"
    echo "✅ Remote repository added"
else
    echo "✅ Remote repository already configured"
fi

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push -u origin main || git push origin main

echo ""
echo "✅ Deployment initiated!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to your GitHub repository settings"
echo "2. Navigate to Settings → Pages"
echo "3. Under 'Source', select 'GitHub Actions'"
echo "4. Go to Settings → Secrets → Actions"
echo "5. Add these secrets:"
echo "   - TMDB_API_KEY"
echo "   - BACKEND_API_URL"
echo "   - CORS_PROXY_URL"
echo "6. GitHub Actions will automatically build and deploy your app"
echo ""
echo "🌐 Your app will be live at:"
echo "   https://[your-username].github.io/iptv-web-player/"
echo ""
echo "Happy streaming! 🎬"
