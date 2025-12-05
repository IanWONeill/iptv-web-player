import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';

/// TMDB API Service for enhanced metadata
class TmdbService {
  late final Dio _dio;
  final String _apiKey;
  final String _baseUrl;
  
  TmdbService()
      : _apiKey = AppConfig.tmdbApiKey,
        _baseUrl = AppConfig.tmdbBaseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        queryParameters: {'api_key': _apiKey},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }
  
  /// Search for a movie by title and optional year
  Future<Map<String, dynamic>?> searchMovie(String title, {int? year}) async {
    try {
      final params = <String, dynamic>{'query': title};
      if (year != null) params['year'] = year;
      
      final response = await _dio.get('/search/movie', queryParameters: params);
      final results = response.data['results'] as List?;
      
      return results?.isNotEmpty == true ? results!.first : null;
    } catch (e) {
      print('TMDB search error: $e');
      return null;
    }
  }
  
  /// Search for a TV series by title and optional year
  Future<Map<String, dynamic>?> searchTv(String title, {int? year}) async {
    try {
      final params = <String, dynamic>{'query': title};
      if (year != null) params['first_air_date_year'] = year;
      
      final response = await _dio.get('/search/tv', queryParameters: params);
      final results = response.data['results'] as List?;
      
      return results?.isNotEmpty == true ? results!.first : null;
    } catch (e) {
      print('TMDB search error: $e');
      return null;
    }
  }
  
  /// Get movie details by TMDB ID
  Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {
          'append_to_response': 'credits,videos,images',
        },
      );
      return response.data;
    } catch (e) {
      print('TMDB movie details error: $e');
      return null;
    }
  }
  
  /// Get TV series details by TMDB ID
  Future<Map<String, dynamic>?> getTvDetails(int tvId) async {
    try {
      final response = await _dio.get(
        '/tv/$tvId',
        queryParameters: {
          'append_to_response': 'credits,videos,images',
        },
      );
      return response.data;
    } catch (e) {
      print('TMDB TV details error: $e');
      return null;
    }
  }
  
  /// Build poster URL
  String getPosterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }
  
  /// Build backdrop URL
  String getBackdropUrl(String? path, {String size = 'w1280'}) {
    if (path == null || path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }
}
