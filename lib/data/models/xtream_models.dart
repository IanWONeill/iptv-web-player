import 'package:json_annotation/json_annotation.dart';

part 'xtream_models.g.dart';

/// Custom converter to handle int/String fields from XtreamCodes API
class StringOrIntConverter implements JsonConverter<String, dynamic> {
  const StringOrIntConverter();

  @override
  String fromJson(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  dynamic toJson(String value) => value;
}

/// User authentication info
@JsonSerializable()
class UserInfo {
  @JsonKey(name: 'user_info')
  final UserInfoData userInfo;
  
  @JsonKey(name: 'server_info')
  final ServerInfo serverInfo;
  
  UserInfo({
    required this.userInfo,
    required this.serverInfo,
  });
  
  factory UserInfo.fromJson(Map<String, dynamic> json) => 
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable()
class UserInfoData {
  final String username;
  final String password;
  final String message;
  
  @StringOrIntConverter()
  final String auth;
  
  @StringOrIntConverter()
  final String status;
  
  @JsonKey(name: 'exp_date')
  @StringOrIntConverter()
  final String? expDate;
  
  @JsonKey(name: 'is_trial')
  @StringOrIntConverter()
  final String? isTrial;
  
  @JsonKey(name: 'active_cons')
  @StringOrIntConverter()
  final String? activeCons;
  
  @JsonKey(name: 'created_at')
  @StringOrIntConverter()
  final String? createdAt;
  
  @JsonKey(name: 'max_connections')
  @StringOrIntConverter()
  final String? maxConnections;
  
  @JsonKey(name: 'allowed_output_formats')
  final List<String>? allowedOutputFormats;
  
  UserInfoData({
    required this.username,
    required this.password,
    required this.message,
    required this.auth,
    required this.status,
    this.expDate,
    this.isTrial,
    this.activeCons,
    this.createdAt,
    this.maxConnections,
    this.allowedOutputFormats,
  });
  
  factory UserInfoData.fromJson(Map<String, dynamic> json) => 
      _$UserInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoDataToJson(this);
}

@JsonSerializable()
class ServerInfo {
  @StringOrIntConverter()
  final String url;
  
  @StringOrIntConverter()
  final String port;
  
  @JsonKey(name: 'https_port')
  @StringOrIntConverter()
  final String? httpsPort;
  
  @JsonKey(name: 'server_protocol')
  final String? serverProtocol;
  
  @JsonKey(name: 'rtmp_port')
  @StringOrIntConverter()
  final String? rtmpPort;
  
  final String? timezone;
  
  @JsonKey(name: 'timestamp_now')
  final int? timestampNow;
  
  @JsonKey(name: 'time_now')
  final String? timeNow;
  
  ServerInfo({
    required this.url,
    required this.port,
    this.httpsPort,
    this.serverProtocol,
    this.rtmpPort,
    this.timezone,
    this.timestampNow,
    this.timeNow,
  });
  
  factory ServerInfo.fromJson(Map<String, dynamic> json) => 
      _$ServerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ServerInfoToJson(this);
}

/// Category model (used for Live TV, VOD, and Series)
@JsonSerializable()
class Category {
  @JsonKey(name: 'category_id')
  final String categoryId;
  
  @JsonKey(name: 'category_name')
  final String categoryName;
  
  @JsonKey(name: 'parent_id')
  final int? parentId;
  
  Category({
    required this.categoryId,
    required this.categoryName,
    this.parentId,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) => 
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

/// Live stream model
@JsonSerializable()
class LiveStream {
  final int num;
  final String name;
  
  @JsonKey(name: 'stream_type')
  final String streamType;
  
  @JsonKey(name: 'stream_id')
  final int streamId;
  
  @JsonKey(name: 'stream_icon')
  final String? streamIcon;
  
  @JsonKey(name: 'epg_channel_id')
  final String? epgChannelId;
  
  @JsonKey(name: 'added')
  final String? added;
  
  @JsonKey(name: 'category_id')
  final String? categoryId;
  
  @JsonKey(name: 'custom_sid')
  final String? customSid;
  
  @JsonKey(name: 'tv_archive')
  final int? tvArchive;
  
  @JsonKey(name: 'direct_source')
  final String? directSource;
  
  @JsonKey(name: 'tv_archive_duration')
  final int? tvArchiveDuration;
  
  LiveStream({
    required this.num,
    required this.name,
    required this.streamType,
    required this.streamId,
    this.streamIcon,
    this.epgChannelId,
    this.added,
    this.categoryId,
    this.customSid,
    this.tvArchive,
    this.directSource,
    this.tvArchiveDuration,
  });
  
  factory LiveStream.fromJson(Map<String, dynamic> json) => 
      _$LiveStreamFromJson(json);
  Map<String, dynamic> toJson() => _$LiveStreamToJson(this);
}

/// VOD stream model
@JsonSerializable()
class VodStream {
  final int num;
  final String name;
  
  @JsonKey(name: 'stream_type')
  final String streamType;
  
  @JsonKey(name: 'stream_id')
  final int streamId;
  
  @JsonKey(name: 'stream_icon')
  final String? streamIcon;
  
  @JsonKey(name: 'rating')
  final String? rating;
  
  @JsonKey(name: 'rating_5based')
  final double? rating5based;
  
  @JsonKey(name: 'added')
  final String? added;
  
  @JsonKey(name: 'category_id')
  final String? categoryId;
  
  @JsonKey(name: 'container_extension')
  final String? containerExtension;
  
  @JsonKey(name: 'custom_sid')
  final String? customSid;
  
  @JsonKey(name: 'direct_source')
  final String? directSource;
  
  VodStream({
    required this.num,
    required this.name,
    required this.streamType,
    required this.streamId,
    this.streamIcon,
    this.rating,
    this.rating5based,
    this.added,
    this.categoryId,
    this.containerExtension,
    this.customSid,
    this.directSource,
  });
  
  factory VodStream.fromJson(Map<String, dynamic> json) => 
      _$VodStreamFromJson(json);
  Map<String, dynamic> toJson() => _$VodStreamToJson(this);
}

/// VOD detailed info
@JsonSerializable()
class VodInfo {
  final VodInfoData info;
  
  @JsonKey(name: 'movie_data')
  final MovieData? movieData;
  
  VodInfo({
    required this.info,
    this.movieData,
  });
  
  factory VodInfo.fromJson(Map<String, dynamic> json) => 
      _$VodInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VodInfoToJson(this);
}

@JsonSerializable()
class VodInfoData {
  final String? name;
  final String? title;
  final String? year;
  final String? director;
  final String? cast;
  final String? description;
  final String? plot;
  final String? duration;
  final String? genre;
  final String? rating;
  
  @JsonKey(name: 'backdrop_path')
  final List<String>? backdropPath;
  
  @JsonKey(name: 'youtube_trailer')
  final String? youtubeTrailer;
  
  @JsonKey(name: 'tmdb_id')
  final String? tmdbId;
  
  VodInfoData({
    this.name,
    this.title,
    this.year,
    this.director,
    this.cast,
    this.description,
    this.plot,
    this.duration,
    this.genre,
    this.rating,
    this.backdropPath,
    this.youtubeTrailer,
    this.tmdbId,
  });
  
  factory VodInfoData.fromJson(Map<String, dynamic> json) => 
      _$VodInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$VodInfoDataToJson(this);
}

@JsonSerializable()
class MovieData {
  @JsonKey(name: 'stream_id')
  final int? streamId;
  
  final String? name;
  final String? title;
  
  @JsonKey(name: 'container_extension')
  final String? containerExtension;
  
  MovieData({
    this.streamId,
    this.name,
    this.title,
    this.containerExtension,
  });
  
  factory MovieData.fromJson(Map<String, dynamic> json) => 
      _$MovieDataFromJson(json);
  Map<String, dynamic> toJson() => _$MovieDataToJson(this);
}

/// Series model
@JsonSerializable()
class Series {
  final int num;
  final String name;
  final String? title;
  
  @JsonKey(name: 'series_id')
  final int seriesId;
  
  @JsonKey(name: 'cover')
  final String? cover;
  
  @JsonKey(name: 'plot')
  final String? plot;
  
  @JsonKey(name: 'cast')
  final String? cast;
  
  @JsonKey(name: 'director')
  final String? director;
  
  @JsonKey(name: 'genre')
  final String? genre;
  
  @JsonKey(name: 'releaseDate')
  final String? releaseDate;
  
  @JsonKey(name: 'last_modified')
  final String? lastModified;
  
  @JsonKey(name: 'rating')
  final String? rating;
  
  @JsonKey(name: 'rating_5based')
  final double? rating5based;
  
  @JsonKey(name: 'backdrop_path')
  final List<String>? backdropPath;
  
  @JsonKey(name: 'youtube_trailer')
  final String? youtubeTrailer;
  
  @JsonKey(name: 'episode_run_time')
  final String? episodeRunTime;
  
  @JsonKey(name: 'category_id')
  final String? categoryId;
  
  Series({
    required this.num,
    required this.name,
    this.title,
    required this.seriesId,
    this.cover,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.lastModified,
    this.rating,
    this.rating5based,
    this.backdropPath,
    this.youtubeTrailer,
    this.episodeRunTime,
    this.categoryId,
  });
  
  factory Series.fromJson(Map<String, dynamic> json) => 
      _$SeriesFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesToJson(this);
}

/// Series detailed info with episodes
@JsonSerializable()
class SeriesInfo {
  final Map<String, List<Episode>>? episodes;
  final SeriesInfoData? info;
  final Map<String, SeasonInfo>? seasons;
  
  SeriesInfo({
    this.episodes,
    this.info,
    this.seasons,
  });
  
  factory SeriesInfo.fromJson(Map<String, dynamic> json) => 
      _$SeriesInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesInfoToJson(this);
}

@JsonSerializable()
class SeriesInfoData {
  final String? name;
  final String? title;
  final String? year;
  final String? cast;
  final String? director;
  final String? genre;
  final String? plot;
  final String? rating;
  
  @JsonKey(name: 'backdrop_path')
  final List<String>? backdropPath;
  
  SeriesInfoData({
    this.name,
    this.title,
    this.year,
    this.cast,
    this.director,
    this.genre,
    this.plot,
    this.rating,
    this.backdropPath,
  });
  
  factory SeriesInfoData.fromJson(Map<String, dynamic> json) => 
      _$SeriesInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesInfoDataToJson(this);
}

@JsonSerializable()
class Episode {
  final String id;
  
  @JsonKey(name: 'episode_num')
  final int episodeNum;
  
  final String title;
  
  @JsonKey(name: 'container_extension')
  final String containerExtension;
  
  @JsonKey(name: 'info')
  final EpisodeInfo? info;
  
  Episode({
    required this.id,
    required this.episodeNum,
    required this.title,
    required this.containerExtension,
    this.info,
  });
  
  factory Episode.fromJson(Map<String, dynamic> json) => 
      _$EpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}

@JsonSerializable()
class EpisodeInfo {
  @JsonKey(name: 'movie_image')
  final String? movieImage;
  
  final String? plot;
  final String? duration;
  final String? rating;
  
  @JsonKey(name: 'releasedate')
  final String? releaseDate;
  
  EpisodeInfo({
    this.movieImage,
    this.plot,
    this.duration,
    this.rating,
    this.releaseDate,
  });
  
  factory EpisodeInfo.fromJson(Map<String, dynamic> json) => 
      _$EpisodeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeInfoToJson(this);
}

@JsonSerializable()
class SeasonInfo {
  @JsonKey(name: 'air_date')
  final String? airDate;
  
  @JsonKey(name: 'episode_count')
  final int? episodeCount;
  
  final int? id;
  final String? name;
  final String? overview;
  
  @JsonKey(name: 'season_number')
  final int? seasonNumber;
  
  @JsonKey(name: 'cover')
  final String? cover;
  
  SeasonInfo({
    this.airDate,
    this.episodeCount,
    this.id,
    this.name,
    this.overview,
    this.seasonNumber,
    this.cover,
  });
  
  factory SeasonInfo.fromJson(Map<String, dynamic> json) => 
      _$SeasonInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SeasonInfoToJson(this);
}

/// EPG Program model
@JsonSerializable()
class EpgProgram {
  final String? id;
  final String? title;
  
  @JsonKey(name: 'start')
  final String? start;
  
  @JsonKey(name: 'end')
  final String? end;
  
  @JsonKey(name: 'description')
  final String? description;
  
  @JsonKey(name: 'lang')
  final String? lang;
  
  EpgProgram({
    this.id,
    this.title,
    this.start,
    this.end,
    this.description,
    this.lang,
  });
  
  factory EpgProgram.fromJson(Map<String, dynamic> json) => 
      _$EpgProgramFromJson(json);
  Map<String, dynamic> toJson() => _$EpgProgramToJson(this);
}
