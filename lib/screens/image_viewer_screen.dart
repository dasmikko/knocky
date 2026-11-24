import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../widgets/image_gallery/image_gallery.dart';
import '../widgets/media_action_bar.dart';

/// Full-screen image gallery with pinch-to-zoom, double-tap zoom,
/// horizontal swiping between images and swipe-to-dismiss.
///
/// Swipes through [images] (typically the images of one post). When
/// [threadImages] is provided, the user can toggle to swipe through those
/// instead; the choice is persisted in [SettingsService.swipeThreadImages].
class ImageViewerScreen extends StatefulWidget {
  /// Images of the tapped post.
  final List<GalleryImage> images;

  /// All images of the current thread page, if available.
  final List<GalleryImage>? threadImages;

  /// The image the viewer opens on.
  final GalleryImage initialImage;

  /// Called whenever the user swipes to another image.
  final ValueChanged<GalleryImage>? onImageChanged;

  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialImage,
    this.threadImages,
    this.onImageChanged,
  });

  /// A transparent route so the screen below stays laid out (and can scroll
  /// along with the gallery) and is revealed while sliding to dismiss.
  static Route<void> route({
    required List<GalleryImage> images,
    required GalleryImage initialImage,
    List<GalleryImage>? threadImages,
    ValueChanged<GalleryImage>? onImageChanged,
  }) {
    return PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ImageViewerScreen(
            images: images,
            initialImage: initialImage,
            threadImages: threadImages,
            onImageChanged: onImageChanged,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  /// Route for viewing a single image.
  static Route<void> singleRoute({required String url, String? heroTag}) {
    final image = GalleryImage(
      url: url,
      heroTag: heroTag ?? 'image_${url.trim()}',
    );
    return route(images: [image], initialImage: image);
  }

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

  late bool _threadMode;
  late List<GalleryImage> _images;
  late int _index;
  late ExtendedPageController _pageController;

  /// Bumped when switching between post/thread mode to rebuild the page view.
  int _galleryGeneration = 0;

  bool get _canToggleMode {
    final thread = widget.threadImages;
    return thread != null && thread.length > widget.images.length;
  }

  @override
  void initState() {
    super.initState();
    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _threadMode =
        _canToggleMode && context.read<SettingsService>().swipeThreadImages;
    _images = _imagesForMode();
    _index = _indexOf(widget.initialImage);
    _pageController = ExtendedPageController(
      initialPage: _index,
      pageSpacing: 16,
    );
  }

  @override
  void dispose() {
    _doubleTapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<GalleryImage> _imagesForMode() {
    final images = _threadMode ? widget.threadImages! : widget.images;
    return images.isEmpty ? [widget.initialImage] : images;
  }

  /// Finds [image] in the active list, falling back to the same URL (a
  /// quoted copy of the image may live under another post's hero tag).
  int _indexOf(GalleryImage image) {
    final index = _images.indexWhere((i) => i.heroTag == image.heroTag);
    if (index >= 0) return index;
    return max(0, _images.indexWhere((i) => i.url == image.url));
  }

  GalleryImage get _currentImage => _images[_index];

  void _toggleMode() {
    final current = _currentImage;
    final settings = context.read<SettingsService>();
    setState(() {
      _threadMode = !_threadMode;
      _images = _imagesForMode();
      _index = _indexOf(current);
      _pageController.dispose();
      _pageController = ExtendedPageController(
        initialPage: _index,
        pageSpacing: 16,
      );
      _galleryGeneration++;
    });
    settings.setSwipeThreadImages(_threadMode);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _threadMode
                ? 'Swiping through all images in the thread'
                : 'Swiping through images in this post',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

    if (current.heroTag != _currentImage.heroTag) {
      widget.onImageChanged?.call(_currentImage);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    widget.onImageChanged?.call(_images[index]);
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
    final current = _currentImage;
    final hasMultiple = _images.length > 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          current.url.trim(),
          style: const TextStyle(color: Colors.white70),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (hasMultiple)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${_index + 1} / ${_images.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          if (_canToggleMode)
            IconButton(
              icon: Icon(
                _threadMode ? Icons.photo_library : Icons.photo_outlined,
              ),
              tooltip: _threadMode
                  ? 'Swipe images in this post only'
                  : 'Swipe all images in the thread',
              onPressed: _toggleMode,
            ),
        ],
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
            child: ExtendedImageGesturePageView.builder(
              key: ValueKey(_galleryGeneration),
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _GalleryImagePage(
                image: _images[index],
                isCurrent: index == _index,
                inPageView: hasMultiple,
                bottomInset:
                    MediaActionBar.barHeight +
                    MediaQuery.of(context).padding.bottom,
                onDoubleTap: _onDoubleTap,
              ),
            ),
          ),
          MediaActionBar(key: ValueKey(current.url), url: current.url),
        ],
      ),
    );
  }
}

/// A single zoomable, slide-to-dismiss image page in the gallery.
class _GalleryImagePage extends StatelessWidget {
  final GalleryImage image;

  /// Only the visible page uses the real hero tag, so the return animation
  /// targets the image the user ended on.
  final bool isCurrent;
  final bool inPageView;

  /// Space reserved for the action bar. The image is fitted above it when
  /// zoomed out, but still drawn underneath it and can be panned so its
  /// bottom edge clears the bar when zoomed in.
  final double bottomInset;
  final DoubleTap onDoubleTap;

  const _GalleryImagePage({
    required this.image,
    required this.isCurrent,
    required this.inPageView,
    required this.bottomInset,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = image.url.trim();
    final heroTag = isCurrent ? image.heroTag : 'gallery_${image.heroTag}';

    return ExtendedImage.network(
      url,
      cache: true,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      layoutInsets: EdgeInsets.only(bottom: bottomInset),
      mode: ExtendedImageMode.gesture,
      enableSlideOutPage: true,
      heroBuilderForSlidingPage: (Widget result) {
        return Hero(
          tag: heroTag,
          child: result,
          flightShuttleBuilder:
              (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                final hero = toHeroContext.widget as Hero;
                return hero.child;
              },
        );
      },
      initGestureConfigHandler: (state) {
        return GestureConfig(
          minScale: 1.0,
          animationMinScale: 0.8,
          maxScale: 4.0,
          animationMaxScale: 4.5,
          initialScale: 1.0,
          inertialSpeed: 100.0,
          inPageView: inPageView,
        );
      },
      onDoubleTap: onDoubleTap,
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
                  Icon(Icons.broken_image, color: Colors.white54, size: 48),
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
    );
  }
}
