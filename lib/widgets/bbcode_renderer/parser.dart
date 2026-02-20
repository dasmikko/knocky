import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ============================================================================
// DATA CLASSES
// ============================================================================

class BBCodeBlock {
  final String tag;
  final String content;
  final Map<String, String> attributes;

  BBCodeBlock(this.tag, this.content, [this.attributes = const {}]);
}

class BBCodeTagMatch {
  final String tag;
  final int start;
  final int end;
  final String attributes;
  final String content;

  BBCodeTagMatch({
    required this.tag,
    required this.start,
    required this.end,
    required this.attributes,
    required this.content,
  });
}

// ============================================================================
// PARSER
// ============================================================================

class BBCodeParser {
  /// Simple link tags: [tagname]url[/tagname] → tappable link block
  static const linkTags = {
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
  static const customTags = [
    'quote',
    'blockquote',
    'img',
    'video',
    'ol',
    'ul',
    'spoiler',
    'collapse',
    'code',
    'smarturl',
  ];

  /// All block-level tags (link tags + custom tags)
  static List<String> get allTags => [...linkTags.keys, ...customTags];

  // ==========================================================================
  // PRE-PROCESSING
  // ==========================================================================

  static String preNormalize(String text) {
    var result = text;

    // Convert [code inline]...[/code] → [icode]...[/icode] for inline rendering
    // Must run BEFORE block parsing since [code] is a block tag
    result = result.replaceAllMapped(
      RegExp(r'\[code\s+inline\](.*?)\[/code\]', caseSensitive: false, dotAll: true),
      (m) => '[icode]${m.group(1)!}[/icode]',
    );

    // Convert [url smart href="..."]text[/url] → [smarturl]url[/smarturl]
    // Must run BEFORE the generic url href normalization below.
    result = result.replaceAllMapped(
      RegExp(
        r'\[url\s+smart\s+href="([^"]+)"\](.*?)\[/url\]',
        caseSensitive: false,
      ),
      (m) => '[smarturl]${m.group(1)!}[/smarturl]',
    );
    // Handle reversed attribute order: [url href="..." smart]
    result = result.replaceAllMapped(
      RegExp(
        r'\[url\s+href="([^"]+)"\s+smart\](.*?)\[/url\]',
        caseSensitive: false,
      ),
      (m) => '[smarturl]${m.group(1)!}[/smarturl]',
    );

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

  // ==========================================================================
  // BLOCK PARSING
  // ==========================================================================

  static List<BBCodeBlock> parseBlocks(String input) {
    final blocks = <BBCodeBlock>[];
    var remaining = input;

    while (remaining.isNotEmpty) {
      // Find the earliest matching tag
      BBCodeTagMatch? earliest;

      for (final tag in allTags) {
        // Find the opening tag
        final openPattern = RegExp('\\[$tag([^\\]]*)\\]', caseSensitive: false);
        final openMatch = openPattern.firstMatch(remaining);
        if (openMatch == null) continue;

        // Find the matching closing tag (accounting for nesting)
        final closeIndex = findMatchingClose(remaining, tag, openMatch.end);
        if (closeIndex == -1) continue;

        final content = remaining.substring(openMatch.end, closeIndex);
        final end = closeIndex + '[/$tag]'.length;

        if (earliest == null || openMatch.start < earliest.start) {
          earliest = BBCodeTagMatch(
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
          blocks.add(BBCodeBlock('text', remaining));
        }
        break;
      }

      // Text before the tag
      final before = remaining.substring(0, earliest.start);
      if (before.trim().isNotEmpty) {
        blocks.add(BBCodeBlock('text', before));
      }

      // The tag itself
      blocks.add(
        BBCodeBlock(
          earliest.tag,
          earliest.content,
          parseAttributes(earliest.attributes),
        ),
      );

      remaining = remaining.substring(earliest.end);
    }

    return blocks;
  }

  /// Finds the index of the matching closing tag, accounting for nesting.
  /// Returns the start index of the closing tag, or -1 if not found.
  static int findMatchingClose(String input, String tag, int startFrom) {
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

  static Map<String, String> parseAttributes(String attrString) {
    final attrs = <String, String>{};
    // Match key="value" pairs
    final kvPattern = RegExp(r'(\w+)="([^"]*)"');
    for (final match in kvPattern.allMatches(attrString)) {
      attrs[match.group(1)!] = match.group(2)!;
    }
    // Match bare attributes (e.g. "inline", "smart", "thumbnail")
    final stripped = attrString.replaceAll(kvPattern, '').trim();
    for (final word in stripped.split(RegExp(r'\s+'))) {
      if (word.isNotEmpty && RegExp(r'^\w+$').hasMatch(word)) {
        attrs[word] = 'true';
      }
    }
    return attrs;
  }
}
