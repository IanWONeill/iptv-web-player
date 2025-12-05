@echo off
REM IPTV Web Player - Quick Deploy Script (Windows)
REM This script initializes a git repository and deploys to GitHub Pages

echo.
echo 🚀 IPTV Web Player - Deployment Script
echo ======================================
echo.

REM Check if git is initialized
if not exist ".git" (
    echo 📦 Initializing Git repository...
    git init
    git branch -M main
) else (
    echo ✅ Git repository already initialized
)

REM Check if .env exists
if not exist ".env" (
    echo ⚠️  Warning: .env file not found
    echo Please copy .env.example to .env and configure your credentials:
    echo   copy .env.example .env
    echo.
    pause
)

REM Add all files
echo 📝 Adding files to git...
git add .

REM Commit
set /p commit_msg="Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Initial deployment

git commit -m "%commit_msg%" || echo No changes to commit

REM Check for remote
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo.
    echo 🔗 GitHub Repository Setup
    echo Please create a new repository on GitHub first: https://github.com/new
    echo.
    set /p repo_url="Enter your GitHub repository URL (e.g., https://github.com/username/iptv-web-player.git): "
    
    if "%repo_url%"=="" (
        echo ❌ Repository URL is required
        exit /b 1
    )
    
    git remote add origin %repo_url%
    echo ✅ Remote repository added
) else (
    echo ✅ Remote repository already configured
)

REM Push to GitHub
echo.
echo 🚀 Pushing to GitHub...
git push -u origin main || git push origin main

echo.
echo ✅ Deployment initiated!
echo.
echo 📋 Next Steps:
echo 1. Go to your GitHub repository settings
echo 2. Navigate to Settings → Pages
echo 3. Under 'Source', select 'GitHub Actions'
echo 4. Go to Settings → Secrets → Actions
echo 5. Add these secrets:
echo    - TMDB_API_KEY
echo    - BACKEND_API_URL
echo    - CORS_PROXY_URL
echo 6. GitHub Actions will automatically build and deploy your app
echo.
echo 🌐 Your app will be live at:
echo    https://[your-username].github.io/iptv-web-player/
echo.
echo Happy streaming! 🎬
echo.
pause
