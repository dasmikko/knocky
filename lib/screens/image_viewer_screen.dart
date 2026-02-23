import 'dart:math';

import 'package:extended_image/extended_image.dart';
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
  final GlobalKey<ExtendedImageSlidePageState> _slidePageKey =
      GlobalKey<ExtendedImageSlidePageState>();

  late final AnimationController _doubleTapController;
  Animation<double>? _doubleTapAnimation;
  VoidCallback _doubleTapListener = () {};

  @override
  void initState() {
    super.initState();
    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _doubleTapController.dispose();
    super.dispose();
  }

  void _onDoubleTap(ExtendedImageGestureState state) {
    final pointerDownPosition = state.pointerDownPosition;
    final begin = state.gestureDetails!.totalScale!;
    final end = begin == 1.0 ? 3.0 : 1.0;

    _doubleTapAnimation?.removeListener(_doubleTapListener);
    _doubleTapController.stop();
    _doubleTapController.reset();

    _doubleTapListener = () {
      state.handleDoubleTap(
        scale: _doubleTapAnimation!.value,
        doubleTapPosition: pointerDownPosition,
      );
    };

    _doubleTapAnimation = _doubleTapController.drive(
      Tween<double>(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    _doubleTapAnimation!.addListener(_doubleTapListener);
    _doubleTapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          ExtendedImageSlidePage(
            key: _slidePageKey,
            slideAxis: SlideAxis.vertical,
            slideType: SlideType.onlyImage,
            slidePageBackgroundHandler: (offset, pageSize) {
              final double opacity = max(
                0.0,
                1.0 - offset.dy.abs() / (pageSize.height / 2.0),
              );
              return Colors.black.withValues(alpha: opacity);
            },
            slideEndHandler:
                (
                  offset, {
                  ExtendedImageSlidePageState? state,
                  ScaleEndDetails? details,
                }) {
                  // Dismiss if dragged more than 1/6 of page height or flung fast
                  final threshold = state!.pageSize.height / 6;
                  final velocity =
                      details?.velocity.pixelsPerSecond.dy.abs() ?? 0.0;
                  return offset.dy.abs() > threshold || velocity > 800;
                },
            child: Hero(
              tag: widget.heroTag ?? 'image_${widget.url.trim()}',
              child: ExtendedImage.network(
                widget.url.trim(),
                cache: true,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                mode: ExtendedImageMode.gesture,
                enableSlideOutPage: true,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 1.0,
                    animationMinScale: 0.8,
                    maxScale: 4.0,
                    animationMaxScale: 4.5,
                    initialScale: 1.0,
                    inertialSpeed: 100.0,
                  );
                },
                onDoubleTap: _onDoubleTap,
                loadStateChanged: (state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    case LoadState.failed:
                      return const Center(
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
                      );
                    case LoadState.completed:
                      if (state.wasSynchronouslyLoaded) return null;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) =>
                            Opacity(opacity: value, child: child),
                        child: state.completedWidget,
                      );
                  }
                },
              ),
            ),
          ),
          MediaActionBar(url: widget.url),
        ],
      ),
    );
  }
}
