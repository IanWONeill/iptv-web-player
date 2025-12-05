import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';

/// Multi-tier CORS proxy service
/// Implements fallback strategy for overcoming CORS restrictions on static hosting
class CorsProxyService {
  final Dio _dio;
  final Logger _logger = Logger();
  
  // Proxy tier configuration
  final List<CorsProxyTier> _proxyTiers = [];
  int _currentTierIndex = 0;
  
  CorsProxyService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(milliseconds: AppConstants.defaultTimeout),
            receiveTimeout: const Duration(milliseconds: AppConstants.streamTimeout),
          ),
        ) {
    _initializeProxyTiers();
  }
  
  /// Initialize proxy tier hierarchy
  void _initializeProxyTiers() {
    // Tier 1: Cloudflare Worker (Primary)
    if (AppConfig.corsProxyUrl.isNotEmpty) {
      _proxyTiers.add(CorsProxyTier(
        name: 'Cloudflare Worker',
        priority: 1,
        proxyUrl: AppConfig.corsProxyUrl,
        type: ProxyType.cloudflareWorker,
      ));
    }
    
    // Tier 2: PHP Backend Proxy (if available)
    if (AppConfig.backendApiUrl.isNotEmpty) {
      _proxyTiers.add(CorsProxyTier(
        name: 'PHP Backend',
        priority: 2,
        proxyUrl: '${AppConfig.backendApiUrl}/proxy.php',
        type: ProxyType.phpProxy,
      ));
    }
    
    // Tier 3: Public CORS proxies (Fallback)
    _addPublicProxies();
    
    _logger.i('Initialized ${_proxyTiers.length} CORS proxy tiers');
  }
  
  /// Add known public CORS proxy services
  void _addPublicProxies() {
    final publicProxies = [
      'https://api.allorigins.win/raw?url=',
      'https://corsproxy.io/?',
      'https://cors-anywhere.herokuapp.com/',
    ];
    
    for (int i = 0; i < publicProxies.length; i++) {
      _proxyTiers.add(CorsProxyTier(
        name: 'Public Proxy ${i + 1}',
        priority: 3 + i,
        proxyUrl: publicProxies[i],
        type: ProxyType.publicProxy,
      ));
    }
  }
  
  /// Proxy a URL through the current tier
  Future<String> proxyUrl(String originalUrl) async {
    if (_proxyTiers.isEmpty) {
      _logger.w('No proxy tiers available, returning original URL');
      return originalUrl;
    }
    
    for (int attempt = 0; attempt < AppConstants.maxCorsRetries; attempt++) {
      try {
        final tier = _proxyTiers[_currentTierIndex];
        final proxiedUrl = _buildProxiedUrl(tier, originalUrl);
        
        // Test the proxied URL
        await _testProxiedUrl(proxiedUrl);
        
        _logger.i('Successfully proxied URL through ${tier.name}');
        return proxiedUrl;
      } catch (e) {
        _logger.w('Proxy attempt ${attempt + 1} failed: $e');
        
        if (attempt < AppConstants.maxCorsRetries - 1) {
          // Try next tier
          _currentTierIndex = (_currentTierIndex + 1) % _proxyTiers.length;
          await Future.delayed(
            const Duration(milliseconds: AppConstants.corsRetryDelayMs),
          );
        }
      }
    }
    
    // All tiers failed, return original URL as last resort
    _logger.e('All proxy tiers failed, returning original URL');
    return originalUrl;
  }
  
  /// Proxy an M3U8 playlist and rewrite segment URLs
  Future<String> proxyM3u8Playlist(String playlistUrl) async {
    try {
      // Fetch the playlist through proxy
      final proxiedUrl = await proxyUrl(playlistUrl);
      final response = await _dio.get(proxiedUrl);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch M3U8 playlist: ${response.statusCode}');
      }
      
      final playlistContent = response.data.toString();
      
      // Rewrite segment URLs in the playlist
      final rewrittenPlaylist = await _rewriteM3u8Segments(
        playlistContent,
        playlistUrl,
      );
      
      return rewrittenPlaylist;
    } catch (e) {
      _logger.e('Failed to proxy M3U8 playlist: $e');
      rethrow;
    }
  }
  
  /// Rewrite segment URLs in M3U8 playlist content
  Future<String> _rewriteM3u8Segments(String content, String baseUrl) async {
    final lines = content.split('\n');
    final rewrittenLines = <String>[];
    
    final baseUri = Uri.parse(baseUrl);
    
    for (final line in lines) {
      if (line.startsWith('#') || line.trim().isEmpty) {
        // Keep comments and metadata as-is
        rewrittenLines.add(line);
      } else {
        // This is a segment URL, rewrite it
        final segmentUrl = _resolveUrl(line.trim(), baseUri);
        final proxiedSegmentUrl = await proxyUrl(segmentUrl);
        rewrittenLines.add(proxiedSegmentUrl);
      }
    }
    
    return rewrittenLines.join('\n');
  }
  
  /// Build proxied URL based on tier type
  String _buildProxiedUrl(CorsProxyTier tier, String originalUrl) {
    switch (tier.type) {
      case ProxyType.cloudflareWorker:
        // Cloudflare Worker expects URL as query param
        return '${tier.proxyUrl}?url=${Uri.encodeComponent(originalUrl)}';
      
      case ProxyType.phpProxy:
        // PHP proxy expects URL as query param
        return '${tier.proxyUrl}?url=${Uri.encodeComponent(originalUrl)}';
      
      case ProxyType.publicProxy:
        // Most public proxies use simple concatenation
        if (tier.proxyUrl.endsWith('?url=') || tier.proxyUrl.endsWith('?')) {
          return '${tier.proxyUrl}${Uri.encodeComponent(originalUrl)}';
        } else {
          return '${tier.proxyUrl}${originalUrl}';
        }
      
      case ProxyType.serviceWorker:
        // Service Worker intercepts at browser level, return original URL
        return originalUrl;
    }
  }
  
  /// Test if a proxied URL is accessible
  Future<void> _testProxiedUrl(String url) async {
    final response = await _dio.head(
      url,
      options: Options(
        validateStatus: (status) => status! < 500,
        followRedirects: true,
      ),
    );
    
    if (response.statusCode! >= 400) {
      throw Exception('Proxy test failed with status: ${response.statusCode}');
    }
  }
  
  /// Resolve relative URLs against base URL
  String _resolveUrl(String url, Uri baseUri) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    return baseUri.resolve(url).toString();
  }
  
  /// Get current proxy tier info
  CorsProxyTier? get currentTier {
    if (_proxyTiers.isEmpty) return null;
    return _proxyTiers[_currentTierIndex];
  }
  
  /// Force switch to specific proxy tier
  void switchToTier(int tierIndex) {
    if (tierIndex >= 0 && tierIndex < _proxyTiers.length) {
      _currentTierIndex = tierIndex;
      _logger.i('Switched to proxy tier: ${_proxyTiers[tierIndex].name}');
    }
  }
  
  /// Get list of all available proxy tiers
  List<CorsProxyTier> get availableTiers => List.unmodifiable(_proxyTiers);
}

/// CORS Proxy Tier configuration
class CorsProxyTier {
  final String name;
  final int priority;
  final String proxyUrl;
  final ProxyType type;
  
  CorsProxyTier({
    required this.name,
    required this.priority,
    required this.proxyUrl,
    required this.type,
  });
}

/// Proxy implementation types
enum ProxyType {
  cloudflareWorker,
  phpProxy,
  publicProxy,
  serviceWorker,
}
