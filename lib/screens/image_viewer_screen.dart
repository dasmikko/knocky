import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/widgets/media_action_bar.dart';

/// Full-screen image viewer with pinch-to-zoom, double-tap zoom,
/// and swipe-to-dismiss support. Optionally participates in Hero
/// transitions via [heroTag].
class ImageViewerScreen extends StatefulWidget {
  /// The network URL of the image to display.
  final String url;

  /// Optional Hero animation tag. Falls back to a URL-based tag if null.
  final String? heroTag;

  const ImageViewerScreen({super.key, required this.url, this.heroTag});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with SingleTickerProviderStateMixin {
  /// Controls the InteractiveViewer's transformation matrix (pan & zoom).
  final _transformationController = TransformationController();

  /// Drives the animated zoom transition on double-tap.
  late final AnimationController _animationController;

  /// The current double-tap zoom animation (null when idle).
  Animation<Matrix4>? _animation;

  // -- Double-tap zoom --
  /// Target scale factor when zooming in via double-tap.
  static const _zoomedScale = 3.0;

  /// Stores where the user double-tapped so zoom centres on that point.
  Offset _doubleTapPosition = Offset.zero;

  // -- Swipe-to-dismiss --
  /// Accumulated drag translation while the user swipes to dismiss.
  Offset _dragOffset = Offset.zero;

  /// Whether a vertical dismiss drag is currently in progress.
  bool _isDragging = false;

  /// Minimum vertical distance (in logical pixels) required to dismiss.
  static const _dismissThreshold = 100.0;

  /// Returns true when the image is zoomed beyond the default 1× scale.
  bool get _isZoomedIn =>
      _transformationController.value.getMaxScaleOnAxis() > 1.01;

  @override
  void initState() {
    super.initState();

    // Listen for zoom/pan changes so we can toggle swipe-to-dismiss availability.
    _transformationController.addListener(_onTransformChanged);

    // Set up the animation controller used for double-tap zoom.
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          // Feed each animation frame back into the transformation controller.
          if (_animation != null) {
            _transformationController.value = _animation!.value;
          }
        });
  }

  /// Called whenever the zoom/pan matrix changes.
  /// Triggers a rebuild so the GestureDetector can enable or disable
  /// vertical drag callbacks depending on whether the image is zoomed in.
  void _onTransformChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  /// Captures the tap position so the zoom can centre on it.
  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  /// Toggles between zoomed-in and zoomed-out states with an animation.
  /// When zooming in, the image centres on the double-tap location.
  void _onDoubleTap() {
    final isZoomedOut = !_isZoomedIn;

    final Matrix4 end;
    if (isZoomedOut) {
      // Translate so the tap point stays centred after scaling.
      final x = -_doubleTapPosition.dx * (_zoomedScale - 1);
      final y = -_doubleTapPosition.dy * (_zoomedScale - 1);
      end = Matrix4.identity()
        ..translateByDouble(x, y, 0.0, 1.0)
        ..scaleByDouble(_zoomedScale, _zoomedScale, 1.0, 1.0);
    } else {
      // Reset to identity (1× scale, no translation).
      end = Matrix4.identity();
    }

    // Animate from the current transform to the target.
    _animation = Matrix4Tween(begin: _transformationController.value, end: end)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animationController.forward(from: 0);
  }

  /// Begins a swipe-to-dismiss gesture (ignored when zoomed in).
  void _onVerticalDragStart(DragStartDetails details) {
    if (_isZoomedIn) return;
    _isDragging = true;
  }

  /// Accumulates vertical drag offset to move the image and fade the background.
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  /// Finalises the swipe gesture: dismisses the screen if the drag distance or
  /// fling velocity exceeds the threshold, otherwise snaps back to origin.
  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.velocity.pixelsPerSecond.dy;
    if (_dragOffset.dy.abs() > _dismissThreshold || velocity.abs() > 800) {
      Navigator.of(context).pop();
    } else {
      // Snap back – the drag didn't exceed the dismiss threshold.
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Derive visual feedback from the current drag distance:
    //   - progress  : 0 → 1 as the user drags further
    //   - bgOpacity : fades the background from opaque to transparent
    //   - scale     : shrinks the image slightly during the drag
    final progress = (_dragOffset.dy.abs() / 300).clamp(0.0, 1.0);
    final bgOpacity = 1.0 - progress;
    final scale = 1.0 - (progress * 0.3);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: bgOpacity),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.url.trim(),
          style: const TextStyle(color: Colors.white70),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap: _onDoubleTap,
            // Disable swipe-to-dismiss when the image is zoomed in so
            // InteractiveViewer can handle panning instead.
            onVerticalDragStart: _isZoomedIn ? null : _onVerticalDragStart,
            onVerticalDragUpdate: _isZoomedIn ? null : _onVerticalDragUpdate,
            onVerticalDragEnd: _isZoomedIn ? null : _onVerticalDragEnd,
            child: Transform(
              // Apply the swipe-to-dismiss translation and scale.
              transform: Matrix4.identity()
                ..translateByDouble(_dragOffset.dx, _dragOffset.dy, 0.0, 1.0)
                ..scaleByDouble(scale, scale, 1.0, 1.0),
              alignment: Alignment.center,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: widget.heroTag ?? 'image_${widget.url.trim()}',
                    child: CachedNetworkImage(
                      imageUrl: widget.url.trim(),
                      fit: BoxFit.contain,
                      // Show a spinner while the image is loading.
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      // Display a fallback icon and message on load failure.
                      errorWidget: (context, url, error) => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          MediaActionBar(url: widget.url),
        ],
      ),
    );
  }
}
