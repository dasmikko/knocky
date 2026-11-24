import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:material_ui/material_ui.dart';
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

/// Matches a single BBCode tag: `[`, an optional `/`, the tag name, whatever
/// follows it, and `]`. The trailing part cannot contain brackets so unclosed
/// tags don't swallow the rest of the post.
final _tagPattern = RegExp(r'\[(/?)([a-zA-Z0-9*]+)([^\[\]]*)\]');

/// Only simple words survive as attribute names; anything else is dropped.
final _simpleFlagPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

/// Rewrites value-less attributes (`[youtube thumbnail]`) into the `key="value"`
/// form the parser understands.
///
/// Without an `=` anywhere in the tag, bbob folds the attributes into the tag
/// name — `[youtube thumbnail]` becomes a tag literally named
/// `youtube thumbnail`, which matches no renderer and leaves its `[/youtube]`
/// orphaned. Tags simply ignore attributes they don't care about, so keeping
/// the flag around is harmless and unsupported ones are silently ignored.
///
/// Only applied to [validTags] so that plain prose in brackets is left alone.
String normalizeTagAttributes(String text, Set<String> validTags) {
  return text.replaceAllMapped(_tagPattern, (m) {
    final isClosing = m.group(1)!.isNotEmpty;
    final name = m.group(2)!;
    final rest = m.group(3)!;

    if (isClosing || rest.isEmpty) return m.group(0)!;
    if (!validTags.contains(name)) return m.group(0)!;
    // An "=" is already enough for bbob to parse the tag name correctly.
    if (rest.contains('=')) return m.group(0)!;

    final flags = rest.trim().split(RegExp(r'\s+')).where((f) => f.isNotEmpty);
    if (flags.isEmpty || !flags.every(_simpleFlagPattern.hasMatch)) {
      return '[$name]';
    }
    return '[$name ${flags.map((f) => '$f="$f"').join(' ')}]';
  });
}

/// Drops closing tags that have no matching opening tag.
///
/// bbob reports a parse error for an unbalanced closing tag, and
/// `parseBBCode` throws away *every* span when that happens — so a single
/// stray `[/b]` blanks the whole post. Dropping the orphan keeps the rest of
/// the formatting intact.
String dropOrphanedClosingTags(String text, Set<String> validTags) {
  var openTags = 0;
  return text.replaceAllMapped(_tagPattern, (m) {
    final isClosing = m.group(1)!.isNotEmpty;
    final name = m.group(2)!;

    // bbob treats unknown tags as plain text, so they never open or close.
    if (!validTags.contains(name)) return m.group(0)!;

    if (!isClosing) {
      // ...and it only tracks a tag as open when a closing tag exists at all.
      if (text.contains('[/$name')) openTags++;
      return m.group(0)!;
    }

    if (openTags == 0) return '';
    openTags--;
    return m.group(0)!;
  });
}

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

  // Convert [url smart]content[/url] → [smarturl]content[/smarturl] (no href)
  result = result.replaceAllMapped(
    RegExp(
      r'\[url\s+smart\]([^\[]+)\[/url\]',
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

/// Runs the full preprocessing pipeline: normalize → repair → emotes → mentions.
///
/// [validTags] comes from the stylesheet and decides which tags the repair
/// steps are allowed to touch.
String preprocessContent(String text, Set<String> validTags) {
  var result = preNormalize(text);
  result = normalizeTagAttributes(result, validTags);
  result = dropOrphanedClosingTags(result, validTags);
  result = preprocessEmotes(result);
  result = preprocessMentions(result);
  return result;
}
