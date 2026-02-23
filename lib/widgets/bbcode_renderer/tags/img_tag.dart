import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

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
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ExtendedImage.network(
                    url,
                    cache: true,
                    fit: BoxFit.cover,
                    loadStateChanged: (state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Builder(
                            builder: (context) => Container(
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
            ),
          ),
        ),
      ),
    ];
  }
}
