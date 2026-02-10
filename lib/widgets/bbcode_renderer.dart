import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/emotes.dart';
import '../screens/image_viewer_screen.dart';
import '../screens/thread_screen.dart';
import '../screens/video_player_screen.dart';
import 'embed_preview_card.dart';

/// Renders BBCode content as Flutter widgets.
///
/// ## Adding a New Link Block Tag
/// To add a new tag like `[spotify]url[/spotify]`, just add one entry to `_linkTags`:
/// ```dart
/// 'spotify': (label: 'Spotify', icon: Icons.music_note, color: Colors.green),
/// ```
///
/// ## Adding a Custom Block Tag
/// For tags that need custom rendering (not just a link), add to `_customTags`.
class BbcodeRenderer extends StatelessWidget {
  final String content;
  final int? postId;

  const BbcodeRenderer({super.key, required this.content, this.postId});

  // ============================================================================
  // TAG CONFIGURATION - Add new tags here!
  // ============================================================================

  /// Simple link tags: [tagname]url[/tagname] → tappable link block
  static const _linkTags = {
    'youtube': (
      label: 'YouTube',
      icon: FontAwesomeIcons.youtube,
      color: Colors.red,
    ),
    'vimeo': (
      label: 'Vimeo',
      icon: FontAwesomeIcons.vimeo,
      color: Color(0xFF1AB7EA),
    ),
    'streamable': (
      label: 'Streamable',
      icon: Icons.stream,
      color: Color(0xFF0F90FA),
    ),
    'vocaroo': (label: 'Vocaroo', icon: Icons.mic, color: Color(0xFF4CAF50)),
    'spotify': (
      label: 'Spotify',
      icon: Icons.music_note,
      color: Color(0xFF1DB954),
    ),
    'soundcloud': (
      label: 'SoundCloud',
      icon: FontAwesomeIcons.soundcloud,
      color: Color(0xFFFF5500),
    ),
    'twitter': (
      label: 'Twitter',
      icon: FontAwesomeIcons.twitter,
      color: Color(0xFF1DA1F2),
    ),
    'reddit': (
      label: 'Reddit',
      icon: FontAwesomeIcons.reddit,
      color: Colors.deepOrange,
    ),
    'twitch': (
      label: 'Twitch',
      icon: FontAwesomeIcons.twitch,
      color: Colors.purple,
    ),
    'bluesky': (
      label: 'Bluesky',
      icon: FontAwesomeIcons.bluesky,
      color: Color(0xFF0085FF),
    ),
    'instagram': (
      label: 'Instagram',
      icon: FontAwesomeIcons.instagram,
      color: Color(0xFFE1306C),
    ),
    'tiktok': (
      label: 'TikTok',
      icon: FontAwesomeIcons.tiktok,
      color: Color(0xFF010101),
    ),
    'tumblr': (
      label: 'Tumblr',
      icon: FontAwesomeIcons.tumblr,
      color: Color(0xFF36465D),
    ),
    'mastodon': (
      label: 'Mastodon',
      icon: FontAwesomeIcons.mastodon,
      color: Color(0xFF6364FF),
    ),
  };

  /// Custom tags that need special rendering (handled in _buildBlock)
  static const _customTags = [
    'quote',
    'blockquote',
    'img',
    'video',
    'ol',
    'ul',
    'spoiler',
    'collapse',
    'code',
  ];

  // ============================================================================
  // RENDERING
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final normalizedContent = _preNormalize(content);
    final blocks = _parseBlocks(normalizedContent);
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) => _buildBlock(context, block)).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, _Block block) {
    // Check if it's an embed tag - use rich preview cards
    if (_linkTags.containsKey(block.tag)) {
      return EmbedPreviewCard(url: block.content, provider: block.tag);
    }

    // Handle custom tags
    switch (block.tag) {
      case 'text':
        final text = block.content.trim();
        if (text.isEmpty) return const SizedBox.shrink();

        // If text has emotes, use custom renderer that handles both BBCode and emotes
        if (_hasEmotes(text)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildBBCodeWithEmotes(context, text),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BBCodeText(
            data: text,
            stylesheet: _buildStylesheet(context),
            errorBuilder: (context, error, stack) => SelectableText(
              _stripAllBBCode(text),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );

      case 'quote':
        return _buildQuote(context, block);

      case 'blockquote':
        return _buildBlockquote(context, block);

      case 'img':
        return _buildImage(context, block.content);

      case 'video':
        return _buildVideoBlock(context, block.content);

      case 'ol':
        return _buildList(context, block.content, ordered: true);

      case 'ul':
        return _buildList(context, block.content, ordered: false);

      case 'spoiler':
        return _buildSpoiler(context, block);

      case 'collapse':
        return _buildCollapse(context, block);

      case 'code':
        return _buildCode(context, block);

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================================
  // PARSING
  // ============================================================================

  /// All block-level tags (link tags + custom tags)
  static List<String> get _allTags => [..._linkTags.keys, ..._customTags];

  List<_Block> _parseBlocks(String input) {
    final blocks = <_Block>[];
    var remaining = input;

    while (remaining.isNotEmpty) {
      // Find the earliest matching tag
      _TagMatch? earliest;

      for (final tag in _allTags) {
        // Find the opening tag
        final openPattern = RegExp('\\[$tag([^\\]]*)\\]', caseSensitive: false);
        final openMatch = openPattern.firstMatch(remaining);
        if (openMatch == null) continue;

        // Find the matching closing tag (accounting for nesting)
        final closeIndex = _findMatchingClose(remaining, tag, openMatch.end);
        if (closeIndex == -1) continue;

        final content = remaining.substring(openMatch.end, closeIndex);
        final end = closeIndex + '[/$tag]'.length;

        if (earliest == null || openMatch.start < earliest.start) {
          earliest = _TagMatch(
            tag: tag,
            start: openMatch.start,
            end: end,
            attributes: openMatch.group(1) ?? '',
            content: content,
          );
        }
      }

      if (earliest == null) {
        // No more tags - rest is text
        if (remaining.trim().isNotEmpty) {
          blocks.add(_Block('text', remaining));
        }
        break;
      }

      // Text before the tag
      final before = remaining.substring(0, earliest.start);
      if (before.trim().isNotEmpty) {
        blocks.add(_Block('text', before));
      }

      // The tag itself
      blocks.add(
        _Block(
          earliest.tag,
          earliest.content,
          _parseAttributes(earliest.attributes),
        ),
      );

      remaining = remaining.substring(earliest.end);
    }

    return blocks;
  }

  /// Finds the index of the matching closing tag, accounting for nesting.
  /// Returns the start index of the closing tag, or -1 if not found.
  int _findMatchingClose(String input, String tag, int startFrom) {
    final openPattern = RegExp('\\[$tag[^\\]]*\\]', caseSensitive: false);
    final closePattern = RegExp('\\[/$tag\\]', caseSensitive: false);

    var depth = 1;
    var pos = startFrom;

    while (pos < input.length && depth > 0) {
      final sub = input.substring(pos);
      final nextOpen = openPattern.firstMatch(sub);
      final nextClose = closePattern.firstMatch(sub);

      if (nextClose == null) return -1;

      if (nextOpen != null && nextOpen.start < nextClose.start) {
        depth++;
        pos += nextOpen.end;
      } else {
        depth--;
        if (depth == 0) return pos + nextClose.start;
        pos += nextClose.end;
      }
    }

    return -1;
  }

  Map<String, String> _parseAttributes(String attrString) {
    final attrs = <String, String>{};
    final pattern = RegExp(r'(\w+)="([^"]*)"');
    for (final match in pattern.allMatches(attrString)) {
      attrs[match.group(1)!] = match.group(2)!;
    }
    return attrs;
  }

  // ============================================================================
  // PRE-PROCESSING
  // ============================================================================

  String _preNormalize(String text) {
    var result = text;
    // Convert [url href="..."]text[/url] → [url=...]text[/url]
    result = result.replaceAllMapped(
      RegExp(r'\[url href="([^"]+)"\](.*?)\[/url\]', caseSensitive: false),
      (m) =>
          '[url=${m.group(1)!}]${m.group(2)!.isNotEmpty ? m.group(2)! : m.group(1)!}[/url]',
    );
    // Convert [URL]link[/URL] → [URL=link]link[/URL]
    result = result.replaceAllMapped(
      RegExp(r'\[url\]([^\[]+)\[/url\]', caseSensitive: false),
      (m) => '[url=${m.group(1)!}]${m.group(1)!}[/url]',
    );
    return result;
  }

  /// Check if text contains any emote patterns
  static bool _hasEmotes(String text) {
    return RegExp(r':([a-zA-Z0-9_]+):').hasMatch(text);
  }

  /// Build a widget that renders BBCode text with inline emotes
  Widget _buildBBCodeWithEmotes(BuildContext context, String text) {
    // Split by newlines first to preserve line breaks
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((line) => _buildLineWithEmotes(context, line))
          .toList(),
    );
  }

  /// Build a single line with emotes
  Widget _buildLineWithEmotes(BuildContext context, String line) {
    if (line.isEmpty) {
      return const SizedBox(height: 14); // Empty line height
    }

    final emotePattern = RegExp(r':([a-zA-Z0-9_]+):');
    final segments = <_TextSegment>[];
    var lastEnd = 0;

    for (final match in emotePattern.allMatches(line)) {
      // Add text before the emote
      if (match.start > lastEnd) {
        final textBefore = line.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          segments.add(_TextSegment(textBefore, isEmote: false));
        }
      }

      // Check if this is a valid emote
      final emoteCode = match.group(1)!;
      final emote = emoteMap[emoteCode];

      if (emote != null) {
        segments.add(_TextSegment(emoteCode, isEmote: true, emote: emote));
      } else {
        // Not a valid emote, keep the original text
        segments.add(_TextSegment(match.group(0)!, isEmote: false));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < line.length) {
      final remaining = line.substring(lastEnd);
      if (remaining.isNotEmpty) {
        segments.add(_TextSegment(remaining, isEmote: false));
      }
    }

    // If no emotes found, just render BBCode
    if (segments.every((s) => !s.isEmote)) {
      return BBCodeText(
        data: line,
        stylesheet: _buildStylesheet(context),
        errorBuilder: (context, error, stack) => Text(
          _stripAllBBCode(line),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    // Build a Wrap widget with mixed BBCode text and emotes
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: segments.map((segment) {
        if (segment.isEmote && segment.emote != null) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final emoteAssetPath =
              (isDark && segment.emote!.assetPathDark != null)
              ? segment.emote!.assetPathDark!
              : segment.emote!.assetPath;
          return Tooltip(
            message: segment.emote!.title ?? ':${segment.emote!.code}:',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                height: 18,
                child: Image.asset(
                  emoteAssetPath,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          );
        } else {
          // Render BBCode text segment
          final trimmed = segment.text;
          if (trimmed.isEmpty) return const SizedBox.shrink();
          return BBCodeText(
            data: trimmed,
            stylesheet: _buildStylesheet(context),
            errorBuilder: (context, error, stack) => Text(
              _stripAllBBCode(trimmed),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  BBStylesheet _buildStylesheet(BuildContext context) {
    final theme = Theme.of(context);
    return defaultBBStylesheet(
        textStyle: TextStyle(
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color,
        ),
      )
      ..replaceTag(UrlTag(onTap: _launchUrl))
      ..replaceTag(HeaderTag(1, 22)) // h1 - was ~32 by default
      ..replaceTag(HeaderTag(2, 20)) // h2
      ..replaceTag(HeaderTag(3, 18)) // h3
      ..replaceTag(HeaderTag(4, 16)) // h4
      ..replaceTag(HeaderTag(5, 15)) // h5
      ..replaceTag(HeaderTag(6, 14)); // h6
  }

  String _stripAllBBCode(String text) {
    return text
        .replaceAll(RegExp(r'\[/?[^\]]+\]'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // ============================================================================
  // WIDGET BUILDERS
  // ============================================================================

  Widget _buildQuote(BuildContext context, _Block block) {
    final username = block.attributes['username'] ?? 'Quote';
    final theme = Theme.of(context);

    // Parse navigation attributes
    final threadId = int.tryParse(block.attributes['threadId'] ?? '');
    final threadPage = int.tryParse(block.attributes['threadPage'] ?? '');
    final quotedPostId = int.tryParse(block.attributes['postId'] ?? '');
    final canNavigate = threadId != null && threadPage != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 3),
          ),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: canNavigate
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThreadScreen(
                            threadId: threadId,
                            threadTitle: '',
                            page: threadPage,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(
                '$username posted:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  decoration: canNavigate ? TextDecoration.underline : null,
                  decorationColor: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            BbcodeRenderer(
              content: block.content,
              postId: quotedPostId ?? postId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockquote(BuildContext context, _Block block) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 3),
          ),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: BbcodeRenderer(content: block.content, postId: postId),
      ),
    );
  }

  Widget _buildSpoiler(BuildContext context, _Block block) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use a brighter background that stands out from the post background
    final bgColor = isDark
        ? const Color(0xFF3A4A5C) // Brighter than dark post bg
        : const Color(0xFFD0D0D0); // Darker than light post bg

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _SpoilerWidget(
        backgroundColor: bgColor,
        child: BbcodeRenderer(content: block.content, postId: postId),
      ),
    );
  }

  Widget _buildCollapse(BuildContext context, _Block block) {
    final title = block.attributes['title'] ?? 'Collapsed';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF3A4A5C) : const Color(0xFFD0D0D0);

    final borderColor = isDark
        ? const Color(0xFF1E2E3E)
        : const Color(0xFF999999);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: _CollapseWidget(
        title: title,
        backgroundColor: bgColor,
        borderColor: borderColor,
        child: BbcodeRenderer(content: block.content, postId: postId),
      ),
    );
  }

  Widget _buildCode(BuildContext context, _Block block) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1A1A2E) // Dark code background
        : const Color(0xFFF5F5F5); // Light code background

    final borderColor = isDark
        ? const Color(0xFF2D2D44)
        : const Color(0xFFE0E0E0);

    final textColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF333333);

    // Strip any nested BBCode from code blocks
    final codeContent = block.content
        .replaceAll(RegExp(r'\[/?[^\]]+\]'), '')
        .trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Code',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Code content
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                codeContent,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String content, {
    required bool ordered,
  }) {
    final liPattern = RegExp(
      r'\[li\](.*?)\[/li\]',
      caseSensitive: false,
      dotAll: true,
    );
    final items = liPattern
        .allMatches(content)
        .map((m) => m.group(1) ?? '')
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final bulletWidth = ordered
        ? (items.length.toString().length * 10.0) + 12
        : 16.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          final bullet = ordered ? '${entry.key + 1}.' : '\u2022';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: bulletWidth,
                  child: Text(
                    bullet,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Expanded(
                  child: BbcodeRenderer(
                    content: entry.value.trim(),
                    postId: postId,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String url) {
    final trimmedUrl = url.trim();
    final heroTag = 'image_${postId}_$trimmedUrl';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ImageViewerScreen(url: trimmedUrl, heroTag: heroTag),
          ),
        ),
        child: Hero(
          tag: heroTag,
          child: SizedBox(
            height: 250,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: trimmedUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBlock(BuildContext context, String url) {
    final trimmedUrl = url.trim();
    final filename =
        Uri.tryParse(trimmedUrl)?.pathSegments.lastOrNull ?? 'Video';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoPlayerScreen(url: trimmedUrl)),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 18,
                color: Colors.purple,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  filename,
                  style: const TextStyle(color: Colors.purple, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ============================================================================
// DATA CLASSES
// ============================================================================

class _TagMatch {
  final String tag;
  final int start;
  final int end;
  final String attributes;
  final String content;

  _TagMatch({
    required this.tag,
    required this.start,
    required this.end,
    required this.attributes,
    required this.content,
  });
}

class _Block {
  final String tag;
  final String content;
  final Map<String, String> attributes;

  _Block(this.tag, this.content, [this.attributes = const {}]);
}

class _TextSegment {
  final String text;
  final bool isEmote;
  final Emote? emote;

  _TextSegment(this.text, {required this.isEmote, this.emote});
}

/// A tappable spoiler widget that reveals content when tapped
class _SpoilerWidget extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;

  const _SpoilerWidget({required this.child, required this.backgroundColor});

  @override
  State<_SpoilerWidget> createState() => _SpoilerWidgetState();
}

class _SpoilerWidgetState extends State<_SpoilerWidget>
    with SingleTickerProviderStateMixin {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => setState(() => _isRevealed = !_isRevealed),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedRotation(
                    turns: _isRevealed ? 0.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isRevealed ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRevealed
                        ? 'Spoiler (tap to hide)'
                        : 'Spoiler (tap to reveal)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isRevealed ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.child,
                ),
                crossFadeState: _isRevealed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A collapsible section widget with a custom title
class _CollapseWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  const _CollapseWidget({
    required this.title,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  State<_CollapseWidget> createState() => _CollapseWidgetState();
}

class _CollapseWidgetState extends State<_CollapseWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
