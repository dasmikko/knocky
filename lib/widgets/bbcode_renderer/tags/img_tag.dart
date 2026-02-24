import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

/// In-memory cache of image aspect ratios keyed by URL.
/// Prevents layout jumps when scrolling back to already-loaded images.
final Map<String, double> _aspectRatioCache = {};

const double _fallbackHeight = 250;
const double _maxHeight = 500;

/// [img]url[/img] — image with hero animation and tap to fullscreen.
class KnockoutImgTag extends AdvancedTag {
  final void Function(String url, String heroTag)? onTap;
  final String heroTagPrefix;

  KnockoutImgTag({this.onTap, this.heroTagPrefix = 'image'}) : super('img');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: '[img]', style: renderer.getCurrentStyle())];
    }

    final url = element.children.first.textContent.trim();
    final heroTag = '${heroTagPrefix}_$url';

    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: onTap != null ? () => onTap!(url, heroTag) : null,
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _SizedImage(url: url),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

/// Stateful wrapper that sizes itself from the aspect ratio cache and
/// updates smoothly when image dimensions arrive.
class _SizedImage extends StatefulWidget {
  final String url;
  const _SizedImage({required this.url});

  @override
  State<_SizedImage> createState() => _SizedImageState();
}

class _SizedImageState extends State<_SizedImage> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _aspectRatio = _aspectRatioCache[widget.url];
  }

  void _onImageLoaded(ExtendedImageState state) {
    final info = state.extendedImageInfo;
    if (info == null) return;

    final w = info.image.width.toDouble();
    final h = info.image.height.toDouble();
    if (h <= 0) return;

    final ratio = w / h;
    _aspectRatioCache[widget.url] = ratio;

    if (_aspectRatio == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _aspectRatio = ratio);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ExtendedImage.network(
      widget.url,
      cache: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          case LoadState.failed:
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Image failed to load',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          case LoadState.completed:
            _onImageLoaded(state);
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

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: _aspectRatio != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _maxHeight),
              child: AspectRatio(
                aspectRatio: _aspectRatio!,
                child: child,
              ),
            )
          : SizedBox(
              height: _fallbackHeight,
              width: double.infinity,
              child: child,
            ),
    );
  }
}
