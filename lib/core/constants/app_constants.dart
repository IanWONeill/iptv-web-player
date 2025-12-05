/// Application-wide constants
class AppConstants {
  AppConstants._();
  
  // API Timeouts
  static const int defaultTimeout = 30000; // 30 seconds
  static const int streamTimeout = 60000; // 60 seconds for media
  static const int epgTimeout = 120000; // 2 minutes for EPG
  
  // Storage Keys
  static const String keyUserProfile = 'user_profile';
  static const String keyActiveService = 'active_service';
  static const String keyServices = 'services';
  static const String keyFavorites = 'favorites';
  static const String keyWatchHistory = 'watch_history';
  static const String keyResumePositions = 'resume_positions';
  static const String keyEpgCache = 'epg_cache';
  static const String keyLastEpgUpdate = 'last_epg_update';
  
  // UI Constants
  static const double sideMenuWidth = 280.0;
  static const double miniEpgHeight = 180.0;
  static const double channelListItemHeight = 80.0;
  static const double epgTimeSlotWidth = 120.0;
  static const double epgChannelRowHeight = 60.0;
  
  // Animation Durations
  static const int menuAnimationMs = 250;
  static const int miniEpgAnimationMs = 200;
  static const int channelSwitchDelayMs = 300;
  static const int fadeAnimationMs = 150;
  
  // EPG Settings
  static const int epgHoursForward = 12;
  static const int epgHoursBackward = 6;
  static const int epgPixelsPerHour = 240;
  
  // Video Player Settings
  static const int defaultVideoQuality = 720;
  static const double defaultPlaybackSpeed = 1.0;
  static const List<double> playbackSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  
  // Pagination
  static const int itemsPerPage = 50;
  static const int vodGridColumns = 6;
  static const int seriesGridColumns = 5;
  
  // Image Sizes (TMDB)
  static const String tmdbPosterSize = 'w500';
  static const String tmdbBackdropSize = 'w1280';
  static const String tmdbProfileSize = 'w185';
  
  // CORS Proxy Retry
  static const int maxCorsRetries = 3;
  static const int corsRetryDelayMs = 1000;
}

/// Content types
enum ContentType {
  liveTV,
  vod,
  series,
}

/// Player states
enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  buffering,
  error,
}

/// EPG view modes
enum EpgViewMode {
  full,
  mini,
  timeline,
}

/// Video quality presets
enum VideoQuality {
  auto,
  low,      // 360p
  medium,   // 480p
  high,     // 720p
  full,     // 1080p
  ultra,    // 4K
}

/// Stream types
enum StreamType {
  hls,
  dash,
  direct,
}

/// Subtitle types
enum SubtitleType {
  embedded,
  external,
  none,
}
