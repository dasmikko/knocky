import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import 'embed_preview_card.dart';

/// [smarturl]url[/smarturl] — auto-detect provider and show embed preview.
class SmartUrlTag extends AdvancedTag {
  SmartUrlTag() : super('smarturl');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) return [];

    final url = element.children.first.textContent.trim();
    final provider = _detectProvider(url);

    return [
      WidgetSpan(child: EmbedPreviewCard(url: url, provider: provider)),
    ];
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
}
