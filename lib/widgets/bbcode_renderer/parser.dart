import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/emotes.dart';

// =============================================================================
// LINK TAG REGISTRY
// =============================================================================

/// Metadata for link-embed tags ([youtube], [twitter], etc.).
/// Used by the stylesheet builder to register a LinkEmbedTag per provider.
const linkTags = {
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

// =============================================================================
// TEXT PRE-PROCESSING
// =============================================================================

/// Normalizes non-standard BBCode syntax into standard forms that the
/// bbob parser can handle.
String preNormalize(String text) {
  var result = text;

  // Convert [li]...[/li] → [*]...[/*] for built-in list support
  result = result.replaceAll(RegExp(r'\[li\]', caseSensitive: false), '[*]');
  result = result.replaceAll(RegExp(r'\[/li\]', caseSensitive: false), '[/*]');

  // Strip thumbnail attribute from img tags: [img thumbnail]...[/img] → [img]...[/img]
  result = result.replaceAll(
    RegExp(r'\[img\s+thumb(?:nail)?\]', caseSensitive: false),
    '[img]',
  );

  // Convert [code inline]...[/code] → [icode]...[/icode]
  result = result.replaceAllMapped(
    RegExp(
      r'\[code\s+inline\](.*?)\[/code\]',
      caseSensitive: false,
      dotAll: true,
    ),
    (m) => '[icode]${m.group(1)!}[/icode]',
  );

  // Convert [url smart href="..."]text[/url] → [smarturl]url[/smarturl]
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

/// Converts :emote_code: syntax into [emote=code][/emote] BBCode tags
/// for valid emotes only (checked against the emote map).
String preprocessEmotes(String text) {
  return text.replaceAllMapped(RegExp(r':([a-zA-Z0-9_]+):'), (m) {
    final code = m.group(1)!;
    if (emoteMap.containsKey(code)) {
      return '[emote=$code][/emote]';
    }
    return m.group(0)!; // Not a valid emote, leave as-is
  });
}

/// Converts @<id;...> mention syntax into [mention=id][/mention] BBCode tags.
String preprocessMentions(String text) {
  return text.replaceAllMapped(RegExp(r'@<(\d+);?[^>]*>'), (m) {
    final userId = m.group(1)!;
    return '[mention=$userId][/mention]';
  });
}

/// Serializes bbob parsed nodes back into a BBCode string.
/// Used by container tags (quote, spoiler, etc.) to pass inner content
/// to a nested BbcodeRenderer.
String nodesToBBCode(List<bbob.Node> nodes) {
  final buffer = StringBuffer();
  for (final node in nodes) {
    if (node is bbob.Text) {
      buffer.write(node.text);
    } else if (node is bbob.Element) {
      buffer.write('[${node.tag}');
      for (final attr in node.attributes.entries) {
        if (attr.value.isEmpty) continue;
        if (attr.key == attr.value) {
          // [tag=value] style — bbob stores as {value: value}
          buffer.write('=${attr.value}');
        } else {
          buffer.write(' ${attr.key}="${attr.value}"');
        }
      }
      buffer.write(']');
      buffer.write(nodesToBBCode(node.children));
      buffer.write('[/${node.tag}]');
    }
  }
  return buffer.toString();
}

/// Runs the full preprocessing pipeline: normalize → emotes → mentions.
String preprocessContent(String text) {
  var result = preNormalize(text);
  result = preprocessEmotes(result);
  result = preprocessMentions(result);
  return result;
}
