# Flutter Local Development Setup Script
# Run this script to set up your local Flutter environment

Write-Host "🚀 Setting up Flutter for IPTV Web Player..." -ForegroundColor Cyan

# Add Flutter to PATH for current session
$flutterBin = "C:\flutter\bin"
if ($env:PATH -notlike "*$flutterBin*") {
    $env:PATH = "$flutterBin;$env:PATH"
    Write-Host "✅ Added Flutter to PATH for this session" -ForegroundColor Green
}

# Check Flutter installation
Write-Host "`n📦 Running Flutter doctor..." -ForegroundColor Cyan
& flutter doctor -v

# Get Flutter dependencies
Write-Host "`n📥 Getting Flutter dependencies..." -ForegroundColor Cyan
& flutter pub get

# Generate code
Write-Host "`n🔨 Generating code with build_runner..." -ForegroundColor Cyan
& dart run build_runner build --delete-conflicting-outputs

# Check for Chrome
Write-Host "`n🌐 Checking for Chrome..." -ForegroundColor Cyan
& flutter devices

Write-Host "`n✅ Setup complete! You can now:" -ForegroundColor Green
Write-Host "   1. Press F5 to run in debug mode" -ForegroundColor White
Write-Host "   2. Run 'flutter run -d chrome' in terminal" -ForegroundColor White
Write-Host "   3. Run 'flutter build web' to build for production" -ForegroundColor White
Write-Host "`n💡 Tip: Use Ctrl+Shift+D to open the debug panel" -ForegroundColor Yellow
