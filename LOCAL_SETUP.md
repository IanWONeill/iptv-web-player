# Local Flutter Development Setup

This guide will help you set up and run the IPTV Web Player locally for testing and development.

## ✅ Flutter Installed

Flutter SDK has been installed to: `C:\flutter`

## 🚀 Quick Start

### Option 1: Run Setup Script (Recommended)
```powershell
.\setup-flutter.ps1
```

### Option 2: Manual Setup

1. **Add Flutter to PATH** (for current session):
```powershell
$env:PATH = "C:\flutter\bin;$env:PATH"
```

2. **Verify Flutter Installation**:
```powershell
flutter doctor
```

3. **Get Dependencies**:
```powershell
flutter pub get
```

4. **Generate Code**:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

5. **Run the App**:
```powershell
flutter run -d chrome --web-renderer canvaskit
```

## 🎯 Available Commands

| Command | Description |
|---------|-------------|
| `flutter run -d chrome` | Run in Chrome (debug mode) |
| `flutter run -d edge` | Run in Edge (debug mode) |
| `flutter build web --release` | Build for production |
| `flutter pub get` | Get/update dependencies |
| `dart run build_runner build` | Generate code files |
| `flutter clean` | Clean build artifacts |
| `flutter doctor` | Check Flutter setup |

## 🐛 Debug in VS Code

### Method 1: Press F5
1. Open VS Code
2. Press `F5` or go to Run → Start Debugging
3. Select "Flutter Web (Chrome)" from the dropdown
4. The app will launch in Chrome with hot reload enabled

### Method 2: Debug Panel
1. Open Debug panel (`Ctrl+Shift+D`)
2. Select configuration:
   - **Flutter Web (Chrome)** - Debug in Chrome
   - **Flutter Web (Edge)** - Debug in Edge
   - **Flutter Web (Profile)** - Profile mode
   - **Flutter Web (Release)** - Release mode
3. Click the green play button

## 🔥 Hot Reload

When running in debug mode:
- Press `r` in terminal to hot reload
- Press `R` in terminal to hot restart
- Press `h` for help
- Press `q` to quit

In VS Code, hot reload happens automatically when you save files!

## 📁 Project Structure

```
iptv-web-player/
├── lib/
│   ├── main.dart              # App entry point
│   ├── data/                  # Data layer
│   │   ├── models/            # Data models
│   │   ├── repositories/      # Data repositories
│   │   └── services/          # API services
│   ├── domain/                # Business logic
│   └── presentation/          # UI layer
│       ├── screens/           # Screen widgets
│       ├── widgets/           # Reusable widgets
│       └── providers/         # Riverpod providers
├── web/
│   ├── index.html             # Web entry point
│   ├── manifest.json          # PWA manifest
│   └── icons/                 # PWA icons
├── assets/
│   ├── images/                # Images
│   ├── icons/                 # Icons
│   └── fonts/                 # Fonts
└── .env                       # Environment variables
```

## 🔧 Configuration

### Environment Variables (.env)

The `.env` file contains configuration. Update these values for local testing:

```env
TMDB_API_KEY=your_api_key_here
BACKEND_API_URL=http://localhost:3000/api
CORS_PROXY_URL=http://localhost:8787
```

### VS Code Settings

Flutter-specific settings are configured in `.vscode/settings.json`:
- Format on save enabled
- Line length: 80
- Preview UI guides enabled
- Debug settings optimized

## 🌐 Browser Support

The app is optimized for:
- ✅ Chrome (recommended for development)
- ✅ Edge
- ✅ Firefox
- ✅ Safari

## 📊 Performance Tips

1. **Use Profile Mode** for performance testing:
   ```powershell
   flutter run -d chrome --profile --web-renderer canvaskit
   ```

2. **Check Bundle Size**:
   ```powershell
   flutter build web --release
   # Check build/web folder size
   ```

3. **Analyze Performance**:
   - Open Chrome DevTools → Performance tab
   - Open Flutter DevTools: `flutter pub global activate devtools`

## 🐞 Troubleshooting

### Flutter not recognized
```powershell
# Add to PATH for current session
$env:PATH = "C:\flutter\bin;$env:PATH"

# Or add permanently via System Environment Variables
```

### Dependencies issues
```powershell
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Build errors
```powershell
# Clear all caches
flutter clean
Remove-Item -Recurse -Force .dart_tool
flutter pub get
```

### Chrome not detected
```powershell
# List available devices
flutter devices

# If Chrome not listed, try:
flutter config --enable-web
```

## 🎨 Development Workflow

1. **Start Development Server**:
   ```powershell
   flutter run -d chrome
   ```

2. **Make Changes**: Edit files in `lib/`

3. **Hot Reload**: Save file (automatic) or press `r`

4. **Test**: Verify changes in browser

5. **Build**: When ready to deploy:
   ```powershell
   flutter build web --release --web-renderer canvaskit --base-href /iptv-web-player/
   ```

## 📚 Useful Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Web Renderers](https://docs.flutter.dev/development/platform-integration/web/renderers)

## 🆘 Getting Help

- Check `DEPLOYMENT.md` for deployment instructions
- Check `README.md` for project overview
- Run `flutter doctor` to diagnose setup issues
- Check GitHub Actions logs for CI/CD issues

---

**Happy Coding! 🚀**
