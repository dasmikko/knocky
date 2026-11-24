import 'package:flutter/widgets.dart';

/// A single image that can be shown in the image viewer gallery.
class GalleryImage {
  /// The network URL of the image.
  final String url;

  /// Hero tag used by the inline image, so the viewer can animate to/from it.
  final String heroTag;

  /// Id of the post the image belongs to, if any.
  final int? postId;

  /// Index of the owning post within the currently shown thread page.
  final int? postIndex;

  const GalleryImage({
    required this.url,
    required this.heroTag,
    this.postId,
    this.postIndex,
  });
}

/// Keeps track of the build contexts of inline images currently mounted,
/// keyed by hero tag. Used to scroll a list to a specific image.
class ImageAnchorRegistry {
  final Map<String, BuildContext> _anchors = {};

  void register(String heroTag, BuildContext context) {
    _anchors[heroTag] = context;
  }

  void unregister(String heroTag, BuildContext context) {
    if (identical(_anchors[heroTag], context)) _anchors.remove(heroTag);
  }

  BuildContext? operator [](String heroTag) {
    final context = _anchors[heroTag];
    return context != null && context.mounted ? context : null;
  }
}

/// Signature for opening an image in a gallery-aware way.
typedef OpenGalleryImage =
    void Function(
      BuildContext context, {
      required String url,
      required String heroTag,
      int? postId,
    });

/// Lets a screen (e.g. the thread screen) take over how inline images are
/// opened, so the viewer can swipe across more than a single post, and
/// tracks inline image positions via [registry].
class ImageGalleryScope extends InheritedWidget {
  final OpenGalleryImage onOpenImage;
  final ImageAnchorRegistry registry;

  const ImageGalleryScope({
    super.key,
    required this.onOpenImage,
    required this.registry,
    required super.child,
  });

  static ImageGalleryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ImageGalleryScope>();

  @override
  bool updateShouldNotify(ImageGalleryScope oldWidget) =>
      onOpenImage != oldWidget.onOpenImage || registry != oldWidget.registry;
}

/// Registers its location with the nearest [ImageGalleryScope] registry so
/// the image can be scrolled into view.
class ImageAnchor extends StatefulWidget {
  final String heroTag;
  final Widget child;

  const ImageAnchor({super.key, required this.heroTag, required this.child});

  @override
  State<ImageAnchor> createState() => _ImageAnchorState();
}

class _ImageAnchorState extends State<ImageAnchor> {
  ImageAnchorRegistry? _registry;
  String? _registeredTag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(ImageAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heroTag != widget.heroTag) _register();
  }

  void _register() {
    final registry = ImageGalleryScope.maybeOf(context)?.registry;
    if (_registry != null && _registeredTag != null) {
      _registry!.unregister(_registeredTag!, context);
    }
    _registry = registry;
    _registeredTag = widget.heroTag;
    registry?.register(widget.heroTag, context);
  }

  @override
  void dispose() {
    if (_registeredTag != null) _registry?.unregister(_registeredTag!, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
