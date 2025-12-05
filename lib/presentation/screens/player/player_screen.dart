import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js' as js;
import '../../providers/auth_provider.dart';
import '../../providers/channels_provider.dart';
import '../../../data/services/cors_proxy_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String contentType;
  final String contentId;
  final Map<String, dynamic>? contentData;
  
  const PlayerScreen({
    super.key,
    required this.contentType,
    required this.contentId,
    this.contentData,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final String _viewId = 'video-player-${DateTime.now().millisecondsSinceEpoch}';
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    try {
      final xtreamService = ref.read(xtreamServiceProvider);
      final corsProxy = CorsProxyService();
      
      // Build stream URL
      String streamUrl;
      if (widget.contentType == 'live') {
        streamUrl = xtreamService.buildLiveStreamUrl(widget.contentId, 'm3u8');
      } else if (widget.contentType == 'vod') {
        streamUrl = xtreamService.buildVodStreamUrl(widget.contentId, 'm3u8');
      } else {
        streamUrl = xtreamService.buildSeriesStreamUrl(widget.contentId, 'm3u8');
      }

      // Proxy the stream URL
      final proxiedUrl = await corsProxy.proxyUrl(streamUrl);

      // Register the video element
      ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
        final videoElement = html.VideoElement()
          ..id = 'video-$viewId'
          ..controls = true
          ..autoplay = true
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#000000';

        // Initialize HLS.js
        if (js.context.hasProperty('Hls') && js.context['Hls'].callMethod('isSupported')) {
          final hls = js.JsObject(js.context['Hls']);
          hls.callMethod('loadSource', [proxiedUrl]);
          hls.callMethod('attachMedia', [videoElement]);
          
          hls['on'].callMethod('call', [hls, 'MANIFEST_PARSED', js.allowInterop(() {
            setState(() {
              _isLoading = false;
            });
          })]);
          
          hls['on'].callMethod('call', [hls, 'ERROR', js.allowInterop((event, data) {
            setState(() {
              _error = 'Playback error occurred';
              _isLoading = false;
            });
          })]);
        } else if (videoElement.canPlayType('application/vnd.apple.mpegurl').isNotEmpty) {
          // Native HLS support (Safari)
          videoElement.src = proxiedUrl;
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'HLS not supported in this browser';
            _isLoading = false;
          });
        }

        return videoElement;
      });

      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize player: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = ref.watch(selectedChannelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    )
                  : HtmlElementView(viewType: _viewId),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            channel?.name ?? 'Playing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.contentType == 'live')
                            const Text(
                              'Live TV',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tap to toggle controls
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            behavior: HitTestBehavior.translucent,
            child: Container(),
          ),
        ],
      ),
    );
  }
}
