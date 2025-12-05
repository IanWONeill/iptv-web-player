# 🎬 IPTV Web Player

A high-performance, open-source IPTV web player built with Flutter/Dart, featuring XtreamCodes API integration and advanced CORS proxy handling for seamless streaming on static hosting platforms like GitHub Pages.

## ✨ Features

- **Live TV Streaming**: XtreamCodes API integration with channel browsing
- **Video Playback**: HLS.js-powered player with automatic quality selection
- **CORS Proxy System**: Multi-tier proxy strategy (Cloudflare Worker, PHP, Service Worker)
- **M3U8 Rewriting**: Automatic segment URL proxying for seamless playback
- **TMDB Integration**: Enhanced movie/series metadata with posters and details
- **Responsive UI**: Dark theme optimized for TV viewing experience
- **Static Hosting**: Deployable to GitHub Pages with automated CI/CD

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.16+ ([Install](https://docs.flutter.dev/get-started/install))
- TMDB API Key ([Get Free Key](https://www.themoviedb.org/settings/api))
- Cloudflare Account ([Sign Up Free](https://dash.cloudflare.com/sign-up))
- PHP Hosting (optional, for backend API)

### Installation

1. **Clone and Setup**
```bash
git clone https://github.com/yourusername/iptv-web-player.git
cd iptv-web-player
flutter pub get
```

2. **Configure Environment**
```bash
cp .env.example .env
```

Edit `.env` with your credentials:
```env
TMDB_API_KEY=your_tmdb_api_key
BACKEND_API_URL=https://your-backend.com/api
CORS_PROXY_URL=https://your-worker.workers.dev
```

3. **Run Locally**
```bash
flutter run -d chrome --web-renderer canvaskit
```

## 🌐 Deployment

### Deploy Cloudflare Worker (5 minutes)

1. Create new Worker at [workers.cloudflare.com](https://workers.cloudflare.com)
2. Copy code from `cloudflare-worker/cors-proxy.js`
3. Deploy and note your Worker URL
4. Add URL to `.env` as `CORS_PROXY_URL`

### Deploy PHP Backend (Optional)

Upload `backend/` folder to your PHP hosting:
```
backend/
├── api/
│   ├── config.php
│   ├── services.php
│   └── proxy.php
└── config/
    └── settings.json
```

Configure `settings.json` with your IPTV services.

### Deploy to GitHub Pages

1. **Setup Repository**
   - Create repository on GitHub
   - Enable GitHub Pages: Settings → Pages → Source: GitHub Actions

2. **Add Secrets**
   Go to Settings → Secrets → Actions and add:
   - `TMDB_API_KEY`
   - `BACKEND_API_URL`
   - `CORS_PROXY_URL`

3. **Deploy**
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

GitHub Actions will automatically build and deploy!

Live at: `https://yourusername.github.io/iptv-web-player/`

## � Configuration

### Backend Settings (`backend/config/settings.json`)

```json
{
  "app_name": "IPTV Player",
  "logo_url": "https://example.com/logo.png",
  "primary_color": "#1a73e8",
  "services": [
    {
      "id": "provider1",
      "name": "My IPTV Provider",
      "url": "http://provider.com:8080",
      "description": "Primary IPTV service"
    }
  ],
  "features": {
    "enable_vod": true,
    "enable_series": true,
    "enable_epg": true
  }
}
```

### CORS Proxy Tiers

The app uses a multi-tier failover strategy:

1. **Cloudflare Worker** (Primary) - Fastest, global CDN
2. **PHP Backend Proxy** (Fallback) - Your hosting
3. **Service Worker** (Browser-level) - Direct interception
4. **Public Proxies** (Last resort) - Community services

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## ⚠️ Disclaimer

This player is designed for legal IPTV services. Users are responsible for ensuring they have proper rights to access content through their IPTV providers.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using Flutter & Dart**
