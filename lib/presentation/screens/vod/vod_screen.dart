import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/channels_provider.dart';
import '../../../data/models/xtream_models.dart';
import '../../../data/services/tmdb_service.dart';
import '../player/player_screen.dart';

class VodScreen extends ConsumerStatefulWidget {
  const VodScreen({super.key});

  @override
  ConsumerState<VodScreen> createState() => _VodScreenState();
}

class _VodScreenState extends ConsumerState<VodScreen> {
  String? _selectedCategory;
  final _tmdbService = TmdbService();

  @override
  Widget build(BuildContext context) {
    final vodCategoriesAsync = ref.watch(vodCategoriesProvider);
    final vodStreamsAsync = ref.watch(vodStreamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies & VOD'),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      backgroundColor: const Color(0xFF0f0f1e),
      body: Row(
        children: [
          // Categories sidebar
          Container(
            width: 240,
            color: const Color(0xFF1a1a2e),
            child: vodCategoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (categories) => ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category.categoryId;
                  
                  return ListTile(
                    title: Text(
                      category.categoryName,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF00d9ff) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF2a2a3e),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.categoryId;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          
          // VOD grid
          Expanded(
            child: vodStreamsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error loading movies: $err', style: const TextStyle(color: Colors.white)),
              ),
              data: (allStreams) {
                final streams = _selectedCategory == null
                    ? allStreams
                    : allStreams.where((s) => s.categoryId == _selectedCategory).toList();

                if (streams.isEmpty) {
                  return const Center(
                    child: Text('No movies available', style: TextStyle(color: Colors.white70)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.67,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: streams.length,
                  itemBuilder: (context, index) {
                    final stream = streams[index];
                    return _VodCard(stream: stream, tmdbService: _tmdbService);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VodCard extends StatefulWidget {
  final VodStream stream;
  final TmdbService tmdbService;

  const _VodCard({required this.stream, required this.tmdbService});

  @override
  State<_VodCard> createState() => _VodCardState();
}

class _VodCardState extends State<_VodCard> {
  String? _tmdbPoster;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTmdbData();
  }

  Future<void> _loadTmdbData() async {
    try {
      final results = await widget.tmdbService.searchMovie(widget.stream.name);
      if (results != null && results.isNotEmpty && mounted) {
        setState(() {
          _tmdbPoster = results[0]['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w342${results[0]['poster_path']}'
              : null;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              contentType: 'vod',
              contentId: widget.stream.streamId.toString(),
              contentData: {
                'name': widget.stream.name,
                'stream_icon': widget.stream.streamIcon,
                'container_extension': widget.stream.containerExtension,
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a3e),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : _tmdbPoster != null
                        ? Image.network(
                            _tmdbPoster!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stack) => _fallbackPoster(),
                          )
                        : (widget.stream.streamIcon != null && widget.stream.streamIcon!.isNotEmpty)
                            ? Image.network(
                                widget.stream.streamIcon!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stack) => _fallbackPoster(),
                              )
                            : _fallbackPoster(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            widget.stream.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.stream.rating != null && widget.stream.rating!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFffd700), size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.stream.rating!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _fallbackPoster() {
    return Container(
      color: const Color(0xFF2a2a3e),
      child: Center(
        child: Icon(
          Icons.movie,
          size: 48,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}
