import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global application configuration
class AppConfig {
  static late SharedPreferences _prefs;
  
  // Environment variables
  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbBaseUrl => dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3';
  static String get backendApiUrl => dotenv.env['BACKEND_API_URL'] ?? '';
  static String get corsProxyUrl => dotenv.env['CORS_PROXY_URL'] ?? '';
  
  // App info
  static String get appName => dotenv.env['APP_NAME'] ?? 'IPTV Web Player';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // Feature flags
  static bool get enableTmdbIntegration => 
      dotenv.env['ENABLE_TMDB_INTEGRATION']?.toLowerCase() == 'true';
  static bool get enableMultiService => 
      dotenv.env['ENABLE_MULTI_SERVICE']?.toLowerCase() == 'true';
  static bool get enableOfflineMode => 
      dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase() == 'true';
  static bool get enableChromecast => 
      dotenv.env['ENABLE_CHROMECAST']?.toLowerCase() == 'true';
  
  // Performance settings
  static int get epgCacheDuration => 
      int.tryParse(dotenv.env['EPG_CACHE_DURATION'] ?? '3600') ?? 3600;
  static int get channelPreloadCount => 
      int.tryParse(dotenv.env['CHANNEL_PRELOAD_COUNT'] ?? '3') ?? 3;
  static int get videoBufferSize => 
      int.tryParse(dotenv.env['VIDEO_BUFFER_SIZE'] ?? '30') ?? 30;
  static int get maxRetryAttempts => 
      int.tryParse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '3') ?? 3;
  
  // UI settings (can be overridden by backend)
  static String get defaultTheme => dotenv.env['DEFAULT_THEME'] ?? 'dark';
  static String get primaryColor => dotenv.env['PRIMARY_COLOR'] ?? '#1a73e8';
  static String get accentColor => dotenv.env['ACCENT_COLOR'] ?? '#00bcd4';
  static bool get showChannelNumbers => 
      dotenv.env['SHOW_CHANNEL_NUMBERS']?.toLowerCase() != 'false';
  static int get miniEpgTimeout => 
      int.tryParse(dotenv.env['MINI_EPG_TIMEOUT'] ?? '5000') ?? 5000;
  
  // Remote configuration (loaded from backend)
  static String? _remoteLogo;
  static String? _remotePrimaryColor;
  static String? _remoteAppName;
  
  static String get logoUrl => _remoteLogo ?? '';
  static String get effectivePrimaryColor => _remotePrimaryColor ?? primaryColor;
  static String get effectiveAppName => _remoteAppName ?? appName;
  
  /// Initialize app configuration
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    // Load any cached remote configuration
    _remoteLogo = _prefs.getString('remote_logo');
    _remotePrimaryColor = _prefs.getString('remote_primary_color');
    _remoteAppName = _prefs.getString('remote_app_name');
  }
  
  /// Update remote configuration from backend
  static Future<void> updateRemoteConfig({
    String? logo,
    String? primaryColor,
    String? appName,
  }) async {
    if (logo != null) {
      _remoteLogo = logo;
      await _prefs.setString('remote_logo', logo);
    }
    if (primaryColor != null) {
      _remotePrimaryColor = primaryColor;
      await _prefs.setString('remote_primary_color', primaryColor);
    }
    if (appName != null) {
      _remoteAppName = appName;
      await _prefs.setString('remote_app_name', appName);
    }
  }
  
  /// Get SharedPreferences instance
  static SharedPreferences get prefs => _prefs;
}
