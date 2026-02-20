import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../screens/image_viewer_screen.dart';
import '../../screens/thread_screen.dart';
import '../../screens/video_player_screen.dart';
import '../../services/deep_link_service.dart';
import '../embed_preview_card.dart';
import 'collapse_widget.dart';
import 'inline_renderer.dart';
import 'parser.dart';
import 'spoiler_widget.dart';
import 'stylesheet.dart';

/// Renders BBCode content as Flutter widgets.
///
/// ## Adding a New Link Block Tag
/// To add a new tag like `[spotify]url[/spotify]`, just add one entry to
/// `BBCodeParser.linkTags` in `parser.dart`:
/// ```dart
/// 'spotify': (label: 'Spotify', icon: Icons.music_note, color: Colors.green),
/// ```
///
/// ## Adding a Custom Block Tag
/// For tags that need custom rendering, add to `BBCodeParser.customTags`
/// and handle the new case in `_buildBlock`.
class BbcodeRenderer extends StatelessWidget {
  final String content;
  final int? postId;
  final List<dynamic> mentionUsers;
  final String? heroTagPrefix;

  const BbcodeRenderer({
    super.key,
    required this.content,
    this.postId,
    this.mentionUsers = const [],
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedContent = BBCodeParser.preNormalize(content);
    final blocks = BBCodeParser.parseBlocks(normalizedContent);
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) => _buildBlock(context, block)).toList(),
    );
  }

  // ==========================================================================
  // BLOCK DISPATCH
  // ==========================================================================

  Widget _buildBlock(BuildContext context, BBCodeBlock block) {
    // Check if it's an embed tag - use rich preview cards
    if (BBCodeParser.linkTags.containsKey(block.tag)) {
      return EmbedPreviewCard(url: block.content, provider: block.tag);
    }

    // Handle custom tags
    switch (block.tag) {
      case 'text':
        final text = block.content.trim();
        if (text.isEmpty) return const SizedBox.shrink();

        // If text has emotes, mentions, or inline code, use custom renderer
        if (BBCodeInlineRenderer.needsCustomRenderer(text)) {
          final inlineRenderer =
              BBCodeInlineRenderer(mentionUsers: mentionUsers);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: inlineRenderer.build(
              context,
              text,
              buildBBCodeStylesheet(context, onUrlTap: _launchUrl),
            ),
          );
        }

        final stylesheet =
            buildBBCodeStylesheet(context, onUrlTap: _launchUrl);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BBCodeText(
            data: text,
            stylesheet: stylesheet,
            errorBuilder: (context, error, stack) => SelectableText(
              stripAllBBCode(text),
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

      case 'smarturl':
        return _buildSmartUrl(block);

      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================================================
  // BLOCK BUILDERS
  // ==========================================================================

  Widget _buildSmartUrl(BBCodeBlock block) {
    final url = block.content.trim();
    final provider = _detectProvider(url);
    return EmbedPreviewCard(url: url, provider: provider);
  }

  static String _detectProvider(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return 'link';
    final host = uri.host.toLowerCase();
    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      return 'youtube';
    }
    if (host.contains('vimeo.com')) return 'vimeo';
    if (host.contains('streamable.com')) return 'streamable';
    if (host.contains('vocaroo.com') || host.contains('voca.ro')) {
      return 'vocaroo';
    }
    if (host.contains('spotify.com')) return 'spotify';
    if (host.contains('soundcloud.com')) return 'soundcloud';
    if (host.contains('twitter.com') || host.contains('x.com')) {
      return 'twitter';
    }
    if (host.contains('reddit.com')) return 'reddit';
    if (host.contains('twitch.tv')) return 'twitch';
    if (host.contains('bsky.app')) return 'bluesky';
    if (host.contains('instagram.com')) return 'instagram';
    if (host.contains('tiktok.com')) return 'tiktok';
    if (host.contains('tumblr.com')) return 'tumblr';
    if (host.contains('mastodon.social')) return 'mastodon';
    return 'link';
  }

  Widget _buildQuote(BuildContext context, BBCodeBlock block) {
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
                            scrollToPostId: quotedPostId,
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
              mentionUsers: mentionUsers,
              heroTagPrefix: 'quote_${postId}_$quotedPostId',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockquote(BuildContext context, BBCodeBlock block) {
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
        child: BbcodeRenderer(
          content: block.content,
          postId: postId,
          mentionUsers: mentionUsers,
        ),
      ),
    );
  }

  Widget _buildSpoiler(BuildContext context, BBCodeBlock block) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF3A4A5C)
        : const Color(0xFFD0D0D0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BbcodeSpoiler(
        backgroundColor: bgColor,
        child: BbcodeRenderer(
          content: block.content,
          postId: postId,
          mentionUsers: mentionUsers,
        ),
      ),
    );
  }

  Widget _buildCollapse(BuildContext context, BBCodeBlock block) {
    final title = block.attributes['title'] ?? 'Collapsed';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF3A4A5C) : const Color(0xFFD0D0D0);
    final borderColor =
        isDark ? const Color(0xFF1E2E3E) : const Color(0xFF999999);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: BbcodeCollapse(
        title: title,
        backgroundColor: bgColor,
        borderColor: borderColor,
        child: BbcodeRenderer(
          content: block.content,
          postId: postId,
          mentionUsers: mentionUsers,
        ),
      ),
    );
  }

  Widget _buildCode(BuildContext context, BBCodeBlock block) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFF5F5F5);

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
                    mentionUsers: mentionUsers,
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
    final prefix = heroTagPrefix ?? 'image_$postId';
    final heroTag = '${prefix}_$trimmedUrl';

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
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(url: trimmedUrl),
          ),
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

  // ==========================================================================
  // URL HANDLING
  // ==========================================================================

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Navigate in-app for knockout.chat links
    final route = DeepLinkService.parseUri(uri);
    if (route != null) {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => route));
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
