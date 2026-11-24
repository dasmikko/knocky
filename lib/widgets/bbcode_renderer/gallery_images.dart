import '../image_gallery/image_gallery.dart';
import 'parser.dart';

/// Hero tag prefix used for images rendered in a post. Must match what
/// [KnockoutImgTag] uses so the gallery and inline images line up.
String imageHeroTagPrefix({int? postId, String? heroTagPrefix}) =>
    heroTagPrefix ?? 'image_$postId';

final _codeBlockRegex = RegExp(
  r'\[(i?code)[^\]]*\][\s\S]*?\[/\1\]',
  caseSensitive: false,
);
final _imgRegex = RegExp(
  r'\[img(?:[\s=][^\]]*)?\]([\s\S]*?)\[/img\]',
  caseSensitive: false,
);

/// Extracts all `[img]` images from BBCode [content] in display order.
/// Duplicate images (same hero tag) are only included once.
List<GalleryImage> extractGalleryImages(
  String content, {
  int? postId,
  int? postIndex,
  String? heroTagPrefix,
}) {
  final prefix = imageHeroTagPrefix(
    postId: postId,
    heroTagPrefix: heroTagPrefix,
  );
  // Only [img] matters here, so limit the repair steps to it rather than
  // needing the full stylesheet (which requires a BuildContext).
  final processed = preprocessContent(
    content,
    const {'img'},
  ).replaceAll(_codeBlockRegex, '');

  final seen = <String>{};
  final images = <GalleryImage>[];
  for (final match in _imgRegex.allMatches(processed)) {
    final url = match.group(1)!.trim();
    if (url.isEmpty) continue;
    final heroTag = '${prefix}_$url';
    if (!seen.add(heroTag)) continue;
    images.add(
      GalleryImage(
        url: url,
        heroTag: heroTag,
        postId: postId,
        postIndex: postIndex,
      ),
    );
  }
  return images;
}
