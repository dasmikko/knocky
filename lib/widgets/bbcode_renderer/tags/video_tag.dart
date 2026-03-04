import 'dart:async';
import 'dart:io';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

/// In-memory cache of video aspect ratios keyed by URL.
/// Prevents layout jumps when scrolling back to already-loaded videos.
final Map<String, double> _videoAspectRatioCache = {};

const double _fallbackAspectRatio = 16 / 9;
const double _maxHeight = 500;

/// [video]url[/video] — inline video player with fullscreen option.
class KnockoutVideoTag extends AdvancedTag {
  KnockoutVideoTag() : super('video');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: '[video]', style: renderer.getCurrentStyle())];
    }

    final url = element.children.first.textContent.trim();

    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _InlineVideoPlayer(url: url),
        ),
      ),
    ];
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String url;

  const _InlineVideoPlayer({required this.url});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isScrubbing = false;
  double _scrubPosition = 0.0;
  double? _aspectRatio;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _aspectRatio = _videoAspectRatioCache[widget.url];
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.url.trim()));
    _controller.initialize().then((_) {
      if (mounted) {
        _controller.addListener(_onUpdate);
        final ratio = _controller.value.aspectRatio;
        _videoAspectRatioCache[widget.url] = ratio;
        setState(() {
          _aspectRatio = ratio;
          _isInitialized = true;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  void _onUpdate() {
    if (!_isScrubbing && mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _hideTimer?.cancel();
        _showControls = true;
      } else {
        _controller.play();
        _startHideTimer();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls && _controller.value.isPlaying) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void _openFullscreen() {
    _controller.removeListener(_onUpdate);
    _controller.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoPage(controller: _controller, url: widget.url),
      ),
    ).then((_) {
      if (mounted) {
        _controller.addListener(_onUpdate);
        setState(() {});
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _ErrorPlaceholder(url: widget.url);
    }

    final effectiveRatio = _aspectRatio ?? _fallbackAspectRatio;

    final Widget child;
    if (!_isInitialized) {
      child = Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    } else {
      final duration = _controller.value.duration;
      final position = _isScrubbing
          ? Duration(
              milliseconds:
                  (_scrubPosition * duration.inMilliseconds).round())
          : _controller.value.position;
      final progress = duration.inMilliseconds > 0
          ? (_isScrubbing
              ? _scrubPosition
              : position.inMilliseconds / duration.inMilliseconds)
          : 0.0;

      child = GestureDetector(
        onTap: _controller.value.isPlaying
            ? _toggleControls
            : _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            AnimatedOpacity(
              opacity: !_controller.value.isPlaying ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _PlayButtonOverlay(onTap: _togglePlayPause),
            ),
            IgnorePointer(
              ignoring: !_showControls,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _ControlsOverlay(
                  isPlaying: _controller.value.isPlaying,
                  position: position,
                  duration: duration,
                  progress: progress,
                  formatDuration: _formatDuration,
                  onPlayPause: _togglePlayPause,
                  onFullscreen: _openFullscreen,
                  url: widget.url,
                  onScrubStart: (value) {
                    _isScrubbing = true;
                    _scrubPosition = value;
                  },
                  onScrubUpdate: (value) {
                    setState(() => _scrubPosition = value);
                  },
                  onScrubEnd: (value) {
                    _isScrubbing = false;
                    _controller.seekTo(Duration(
                      milliseconds:
                          (value * duration.inMilliseconds).round(),
                    ));
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.black,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _maxHeight),
            child: AspectRatio(
              aspectRatio: effectiveRatio,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fullscreen video page — reuses the existing controller.
// ---------------------------------------------------------------------------

class _FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final String url;

  const _FullscreenVideoPage({required this.controller, required this.url});

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _showControls = true;
  bool _isScrubbing = false;
  double _scrubPosition = 0.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    widget.controller.addListener(_onUpdate);
    widget.controller.play();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_onUpdate);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _onUpdate() {
    if (!_isScrubbing && mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        _hideTimer?.cancel();
        _showControls = true;
      } else {
        widget.controller.play();
        _startHideTimer();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls && widget.controller.value.isPlaying) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _showMenu(BuildContext context) {
    final url = widget.url;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy URL'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                SharePlus.instance.share(ShareParams(text: url));
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadVideo(context, url);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final duration = controller.value.duration;
    final position = _isScrubbing
        ? Duration(
            milliseconds:
                (_scrubPosition * duration.inMilliseconds).round())
        : controller.value.position;
    final progress = duration.inMilliseconds > 0
        ? (_isScrubbing
            ? _scrubPosition
            : position.inMilliseconds / duration.inMilliseconds)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: controller.value.isPlaying
            ? _toggleControls
            : _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            AnimatedOpacity(
              opacity: !controller.value.isPlaying ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _PlayButtonOverlay(onTap: _togglePlayPause),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 8,
                        child: IconButton(
                          icon: const Icon(
                              Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Bottom controls
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 28,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: Colors.white,
                                    overlayColor: Colors.white24,
                                    trackHeight: 3,
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                            enabledThumbRadius: 7),
                                    overlayShape:
                                        const RoundSliderOverlayShape(
                                            overlayRadius: 14),
                                  ),
                                  child: Slider(
                                    value: progress.clamp(0.0, 1.0),
                                    onChangeStart: (value) {
                                      _isScrubbing = true;
                                      _scrubPosition = value;
                                    },
                                    onChanged: (value) {
                                      setState(
                                          () => _scrubPosition = value);
                                    },
                                    onChangeEnd: (value) {
                                      _isScrubbing = false;
                                      controller.seekTo(Duration(
                                        milliseconds: (value *
                                                duration.inMilliseconds)
                                            .round(),
                                      ));
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 4),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: _togglePlayPause,
                                      icon: Icon(
                                        controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      iconSize: 28,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => _showMenu(context),
                                      icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white),
                                      iconSize: 24,
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      icon: const Icon(
                                          Icons.fullscreen_exit,
                                          color: Colors.white),
                                      iconSize: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _PlayButtonOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const _PlayButtonOverlay({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(12),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double progress;
  final String Function(Duration) formatDuration;
  final VoidCallback onPlayPause;
  final VoidCallback onFullscreen;
  final String url;
  final ValueChanged<double> onScrubStart;
  final ValueChanged<double> onScrubUpdate;
  final ValueChanged<double> onScrubEnd;

  const _ControlsOverlay({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.progress,
    required this.formatDuration,
    required this.onPlayPause,
    required this.onFullscreen,
    required this.url,
    required this.onScrubStart,
    required this.onScrubUpdate,
    required this.onScrubEnd,
  });

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy URL'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                SharePlus.instance.share(ShareParams(text: url));
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadVideo(context, url);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white24,
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChangeStart: onScrubStart,
                  onChanged: onScrubUpdate,
                  onChangeEnd: onScrubEnd,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onPlayPause,
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 40, minHeight: 40),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${formatDuration(position)} / ${formatDuration(duration)}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showMenu(context),
                    icon: const Icon(Icons.more_vert,
                        color: Colors.white),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    onPressed: onFullscreen,
                    icon: const Icon(Icons.fullscreen,
                        color: Colors.white),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _downloadVideo(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final directory = await getApplicationDocumentsDirectory();
    final uri = Uri.parse(url);
    final filename = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'video_${DateTime.now().millisecondsSinceEpoch}';
    final filePath = '${directory.path}/$filename';

    await Dio().download(url, filePath);

    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));

    try {
      await File(filePath).delete();
    } catch (_) {}

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Download complete'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Download failed: $e'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String url;

  const _ErrorPlaceholder({required this.url});

  @override
  Widget build(BuildContext context) {
    final filename = Uri.tryParse(url)?.pathSegments.lastOrNull ?? 'Video';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Failed to load: $filename',
              style: const TextStyle(color: Colors.red, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
