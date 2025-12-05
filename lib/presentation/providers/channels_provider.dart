import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/xtream_codes_service.dart';
import '../../data/models/xtream_models.dart';
import 'auth_provider.dart';

/// Channels state provider
final channelsProvider = FutureProvider<List<LiveStream>>((ref) async {
  final xtreamService = ref.watch(xtreamServiceProvider);
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated) {
    return [];
  }

  try {
    return await xtreamService.getLiveStreams();
  } catch (e) {
    return [];
  }
});

/// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final xtreamService = ref.watch(xtreamServiceProvider);
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated) {
    return [];
  }

  try {
    return await xtreamService.getLiveCategories();
  } catch (e) {
    return [];
  }
});

/// Selected channel provider
final selectedChannelProvider = StateProvider<LiveStream?>((ref) => null);

/// EPG provider for selected channel
final channelEpgProvider = FutureProvider.family<List<EpgProgram>, String>((ref, streamId) async {
  final xtreamService = ref.watch(xtreamServiceProvider);
  
  try {
    return await xtreamService.getShortEpg(streamId, limit: 10);
  } catch (e) {
    return [];
  }
});
