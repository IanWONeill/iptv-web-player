import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/channels_provider.dart';
import '../../../data/models/xtream_models.dart';
import '../../../data/services/tmdb_service.dart';

class SeriesScreen extends ConsumerStatefulWidget {
  const SeriesScreen({super.key});

  @override
  ConsumerState<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends ConsumerState<SeriesScreen> {
  String? _selectedCategory;
  final _tmdbService = TmdbService();

  @override
  Widget build(BuildContext context) {
    final seriesCategoriesAsync = ref.watch(seriesCategoriesProvider);
    final seriesAsync = ref.watch(seriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Series'),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      backgroundColor: const Color(0xFF0f0f1e),
      body: Row(
        children: [
          // Categories sidebar
          Container(
            width: 240,
            color: const Color(0xFF1a1a2e),
            child: seriesCategoriesAsync.when(
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
          
          // Series grid
          Expanded(
            child: seriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error loading series: $err', style: const TextStyle(color: Colors.white)),
              ),
              data: (allSeries) {
                final filteredSeries = _selectedCategory == null
                    ? allSeries
                    : allSeries.where((s) => s.categoryId == _selectedCategory).toList();

                if (filteredSeries.isEmpty) {
                  return const Center(
                    child: Text('No series available', style: TextStyle(color: Colors.white70)),
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
                  itemCount: filteredSeries.length,
                  itemBuilder: (context, index) {
                    final series = filteredSeries[index];
                    return _SeriesCard(series: series, tmdbService: _tmdbService);
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

class _SeriesCard extends StatefulWidget {
  final Series series;
  final TmdbService tmdbService;

  const _SeriesCard({required this.series, required this.tmdbService});

  @override
  State<_SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<_SeriesCard> {
  String? _tmdbPoster;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTmdbData();
  }

  Future<void> _loadTmdbData() async {
    try {
      final results = await widget.tmdbService.searchTvShow(widget.series.name);
      if (results.isNotEmpty && mounted) {
        setState(() {
          _tmdbPoster = results[0]['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w342${results[0]['poster_path']}'
              : null;
          _isLoading = false;
        });
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
        _showEpisodesDialog(context);
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
                        : widget.series.cover.isNotEmpty
                            ? Image.network(
                                widget.series.cover,
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
            widget.series.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.series.rating != null && widget.series.rating! > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFffd700), size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.series.rating!.toStringAsFixed(1),
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
          Icons.tv,
          size: 48,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showEpisodesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          widget.series.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, size: 64, color: Color(0xFF00d9ff)),
                SizedBox(height: 16),
                Text(
                  'Episode viewer coming soon!',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'This feature requires series info API endpoint.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF00d9ff))),
          ),
        ],
      ),
    );
  }
}
