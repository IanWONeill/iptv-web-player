import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/xtream_models.dart';

/// XtreamCodes API Service
/// Handles all XtreamCodes/Xtream-UI API endpoints for Live TV, VOD, Series, and EPG
class XtreamCodesService {
  late final Dio _dio;
  String? _baseUrl;
  String? _username;
  String? _password;
  
  XtreamCodesService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: AppConstants.defaultTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.streamTimeout),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ),
    );
    
    // Add logging interceptor in debug mode
    if (AppConfig.debugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
  
  /// Initialize service with credentials
  void initialize({
    required String baseUrl,
    required String username,
    required String password,
  }) {
    _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), ''); // Remove trailing slash
    _username = username;
    _password = password;
  }
  
  /// Check if service is initialized
  bool get isInitialized => _baseUrl != null && _username != null && _password != null;
  
  /// Get user authentication info
  Future<UserInfo> getUserInfo() async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: {
          'username': _username,
          'password': _password,
          'action': 'get_user_info',
        },
      );
      
      return UserInfo.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get live TV categories
  Future<List<Category>> getLiveCategories() async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: {
          'username': _username,
          'password': _password,
          'action': 'get_live_categories',
        },
      );
      
      return (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get live streams by category
  Future<List<LiveStream>> getLiveStreams({String? categoryId}) async {
    _ensureInitialized();
    
    try {
      final params = {
        'username': _username,
        'password': _password,
        'action': 'get_live_streams',
      };
      
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }
      
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: params,
      );
      
      return (response.data as List)
          .map((json) => LiveStream.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get VOD categories
  Future<List<Category>> getVodCategories() async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: {
          'username': _username,
          'password': _password,
          'action': 'get_vod_categories',
        },
      );
      
      return (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get VOD streams by category
  Future<List<VodStream>> getVodStreams({String? categoryId}) async {
    _ensureInitialized();
    
    try {
      final params = {
        'username': _username,
        'password': _password,
        'action': 'get_vod_streams',
      };
      
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }
      
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: params,
      );
      
      return (response.data as List)
          .map((json) => VodStream.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get VOD info (detailed information)
  Future<VodInfo> getVodInfo(String vodId) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: {
          'username': _username,
          'password': _password,
          'action': 'get_vod_info',
          'vod_id': vodId,
        },
      );
      
      return VodInfo.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get series categories
  Future<List<Category>> getSeriesCategories() async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: {
          'username': _username,
          'password': _password,
          'action': 'get_series_categories',
        },
      );
      
      return (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get series by category
  Future<List<Series>> getSeries({String? categoryId}) async {
    _ensureInitialized();
    
    try {
      final params = {
        'username': _username,
        'password': _password,
        'action': 'get_series',
      };
      
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }
      
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: params,
      );
      
      return (response.data as List)
          .map((json) => Series.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get series info (episodes and seasons)
  Future<SeriesInfo> getSeriesInfo(String seriesId) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: {
          'username': _username,
          'password': _password,
          'action': 'get_series_info',
          'series_id': seriesId,
        },
      );
      
      return SeriesInfo.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get short EPG for a channel
  Future<List<EpgProgram>> getShortEpg(String streamId, {int? limit}) async {
    _ensureInitialized();
    
    try {
      final params = {
        'username': _username,
        'password': _password,
        'action': 'get_short_epg',
        'stream_id': streamId,
      };
      
      if (limit != null) {
        params['limit'] = limit.toString();
      }
      
      final response = await _dio.get(
        '$_baseUrl/player_api.php',
        queryParameters: params,
      );
      
      final epgListings = response.data['epg_listings'] as List? ?? [];
      return epgListings
          .map((json) => EpgProgram.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get full XMLTV EPG (this can be large)
  Future<String> getFullEpg() async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/xmltv.php',
        queryParameters: {
          'username': _username,
          'password': _password,
        },
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(milliseconds: AppConstants.epgTimeout),
        ),
      );
      
      return response.data.toString();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Build stream URL for live TV
  String buildLiveStreamUrl(String streamId, String extension) {
    _ensureInitialized();
    return '$_baseUrl/live/$_username/$_password/$streamId.$extension';
  }
  
  /// Build stream URL for VOD
  String buildVodStreamUrl(String streamId, String extension) {
    _ensureInitialized();
    return '$_baseUrl/movie/$_username/$_password/$streamId.$extension';
  }
  
  /// Build stream URL for series episode
  String buildSeriesStreamUrl(String streamId, String extension) {
    _ensureInitialized();
    return '$_baseUrl/series/$_username/$_password/$streamId.$extension';
  }
  
  /// Ensure service is initialized before API calls
  void _ensureInitialized() {
    if (!isInitialized) {
      throw Exception('XtreamCodesService not initialized. Call initialize() first.');
    }
  }
  
  /// Handle and normalize errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          return Exception('Server error: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unexpected error: $error');
  }
}
