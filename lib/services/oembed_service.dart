import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// Metadata fetched from oEmbed providers
class EmbedMetadata {
  final String provider;
  final String? title;
  final String? authorName;
  final String? authorUrl;
  final String? thumbnailUrl;
  final String? description;
  final String url;

  const EmbedMetadata({
    required this.provider,
    required this.url,
    this.title,
    this.authorName,
    this.authorUrl,
    this.thumbnailUrl,
    this.description,
  });
}

/// Service for fetching embed metadata from oEmbed APIs
class OEmbedService {
  static final OEmbedService _instance = OEmbedService._internal();
  factory OEmbedService() => _instance;

  OEmbedService._internal();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Cache to avoid repeated fetches
  final Map<String, EmbedMetadata> _cache = {};

  // In-flight requests to deduplicate concurrent fetches for the same URL
  final Map<String, Future<EmbedMetadata?>> _pending = {};

  /// Check cache synchronously (useful to avoid loading flicker)
  EmbedMetadata? getCached(String url) => _cache[url.trim()];

  /// Fetch embed metadata for a URL
  Future<EmbedMetadata?> fetchMetadata(String url, String provider) async {
    // Check cache first
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    // Deduplicate: if a request for this URL is already in-flight, await it
    if (_pending.containsKey(url)) {
      return _pending[url];
    }

    final future = _doFetch(url, provider);
    _pending[url] = future;
    try {
      return await future;
    } finally {
      _pending.remove(url);
    }
  }

  Future<EmbedMetadata?> _doFetch(String url, String provider) async {
    try {
      EmbedMetadata? metadata;

      switch (provider) {
        case 'youtube':
          metadata = await _fetchYouTube(url);
        case 'vimeo':
          metadata = await _fetchVimeo(url);
        case 'streamable':
          metadata = await _fetchStreamable(url);
        case 'vocaroo':
          metadata = parseVocaroo(url);
        case 'spotify':
          metadata = await _fetchSpotify(url);
        case 'soundcloud':
          metadata = await _fetchSoundCloud(url);
        case 'twitter':
          metadata = await _fetchTwitter(url);
        case 'reddit':
          metadata = await _fetchReddit(url);
        case 'twitch':
          metadata = await _fetchTwitch(url);
        case 'bluesky':
          metadata = await _fetchBluesky(url);
        case 'instagram':
          metadata = parseInstagram(url);
        case 'tiktok':
          metadata = await _fetchTikTok(url);
        case 'tumblr':
          metadata = parseTumblr(url);
        case 'mastodon':
          metadata = parseMastodon(url);
        default:
          return null;
      }

      if (metadata != null) {
        _cache[url] = metadata;
      }
      return metadata;
    } catch (e) {
      log('Error fetching oEmbed for $url: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchYouTube(String url) async {
    try {
      final response = await _dio.get(
        'https://www.youtube.com/oembed',
        queryParameters: {'url': url, 'format': 'json'},
      );

      final data = response.data;
      return EmbedMetadata(
        provider: 'YouTube',
        url: url,
        title: data['title'],
        authorName: data['author_name'],
        authorUrl: data['author_url'],
        thumbnailUrl: data['thumbnail_url'],
      );
    } catch (e) {
      log('YouTube oEmbed error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchTwitter(String url) async {
    try {
      final response = await _dio.get(
        'https://publish.twitter.com/oembed',
        queryParameters: {'url': url, 'omit_script': true},
      );

      final data = response.data;
      // Twitter returns HTML, extract text content
      String? description;
      if (data['html'] != null) {
        // Extract text from the blockquote
        final html = data['html'] as String;
        final match = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).firstMatch(html);
        if (match != null) {
          description = match.group(1)
              ?.replaceAll(RegExp(r'<[^>]+>'), '') // Remove HTML tags
              .replaceAll('&mdash;', '—')
              .replaceAll('&amp;', '&')
              .replaceAll('&#39;', "'")
              .trim();
        }
      }

      return EmbedMetadata(
        provider: 'Twitter',
        url: url,
        authorName: data['author_name'],
        authorUrl: data['author_url'],
        description: description,
      );
    } catch (e) {
      log('Twitter oEmbed error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchReddit(String url) async {
    try {
      // Reddit's oEmbed endpoint
      final response = await _dio.get(
        'https://www.reddit.com/oembed',
        queryParameters: {'url': url},
      );

      final data = response.data;
      String? description;
      if (data['html'] != null) {
        // Extract title from the HTML
        final html = data['html'] as String;
        final match = RegExp(r'<a[^>]*>([^<]+)</a>', dotAll: true).firstMatch(html);
        description = match?.group(1)?.trim();
      }

      return EmbedMetadata(
        provider: 'Reddit',
        url: url,
        title: data['title'],
        authorName: data['author_name'],
        description: description ?? data['title'],
      );
    } catch (e) {
      log('Reddit oEmbed error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchBluesky(String url) async {
    try {
      // Extract post info from URL: https://bsky.app/profile/{handle}/post/{postId}
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      final segments = uri.pathSegments;
      if (segments.length < 4) return null;

      final handle = segments[1];
      final postId = segments[3];

      // Use Bluesky's public API to get post
      final response = await _dio.get(
        'https://public.api.bsky.app/xrpc/app.bsky.feed.getPostThread',
        queryParameters: {
          'uri': 'at://$handle/app.bsky.feed.post/$postId',
          'depth': 0,
        },
      );

      final thread = response.data['thread'];
      if (thread == null) return null;

      final post = thread['post'];
      final author = post['author'];
      final record = post['record'];

      String? thumbnailUrl;
      if (post['embed']?['images'] != null) {
        final images = post['embed']['images'] as List;
        if (images.isNotEmpty) {
          thumbnailUrl = images[0]['thumb'];
        }
      }

      return EmbedMetadata(
        provider: 'Bluesky',
        url: url,
        authorName: author['displayName'] ?? author['handle'],
        description: record['text'],
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      log('Bluesky API error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchTwitch(String url) async {
    try {
      // Twitch doesn't have a public oEmbed, so extract info from URL
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      String? channelName;
      if (uri.pathSegments.isNotEmpty) {
        channelName = uri.pathSegments.first;
      }

      return EmbedMetadata(
        provider: 'Twitch',
        url: url,
        title: channelName != null ? '$channelName on Twitch' : 'Twitch Stream',
        authorName: channelName,
      );
    } catch (e) {
      log('Twitch parse error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchVimeo(String url) async {
    try {
      final response = await _dio.get(
        'https://vimeo.com/api/oembed.json',
        queryParameters: {'url': url},
      );

      final data = response.data;
      return EmbedMetadata(
        provider: 'Vimeo',
        url: url,
        title: data['title'],
        authorName: data['author_name'],
        authorUrl: data['author_url'],
        thumbnailUrl: data['thumbnail_url'],
      );
    } catch (e) {
      log('Vimeo oEmbed error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchStreamable(String url) async {
    try {
      final response = await _dio.get(
        'https://api.streamable.com/oembed.json',
        queryParameters: {'url': url},
      );

      final data = response.data;
      return EmbedMetadata(
        provider: 'Streamable',
        url: url,
        title: data['title'],
        authorName: data['author_name'],
        thumbnailUrl: data['thumbnail_url'],
      );
    } catch (e) {
      log('Streamable oEmbed error: $e');
      return null;
    }
  }

  @visibleForTesting
  EmbedMetadata parseVocaroo(String url) {
    final uri = Uri.tryParse(url);
    String? id;
    if (uri != null && uri.pathSegments.isNotEmpty) {
      id = uri.pathSegments.last;
    }

    return EmbedMetadata(
      provider: 'Vocaroo',
      url: url,
      title: id != null ? 'Voice recording ($id)' : 'Voice Recording',
    );
  }

  Future<EmbedMetadata?> _fetchSpotify(String url) async {
    try {
      final response = await _dio.get(
        'https://open.spotify.com/oembed',
        queryParameters: {'url': url},
      );

      final data = response.data;
      return EmbedMetadata(
        provider: 'Spotify',
        url: url,
        title: data['title'],
        thumbnailUrl: data['thumbnail_url'],
      );
    } catch (e) {
      log('Spotify oEmbed error: $e');
      return null;
    }
  }

  Future<EmbedMetadata?> _fetchSoundCloud(String url) async {
    try {
      final response = await _dio.get(
        'https://soundcloud.com/oembed',
        queryParameters: {'url': url, 'format': 'json'},
      );

      final data = response.data;
      return EmbedMetadata(
        provider: 'SoundCloud',
        url: url,
        title: data['title'],
        authorName: data['author_name'],
        authorUrl: data['author_url'],
        thumbnailUrl: data['thumbnail_url'],
      );
    } catch (e) {
      log('SoundCloud oEmbed error: $e');
      return null;
    }
  }

  @visibleForTesting
  EmbedMetadata parseInstagram(String url) {
    final uri = Uri.tryParse(url);
    String? username;
    if (uri != null && uri.pathSegments.isNotEmpty) {
      // URLs like instagram.com/p/CODE or instagram.com/USERNAME
      username = uri.pathSegments.first;
    }

    return EmbedMetadata(
      provider: 'Instagram',
      url: url,
      title: username != null ? 'Instagram post by $username' : 'Instagram Post',
    );
  }

  Future<EmbedMetadata?> _fetchTikTok(String url) async {
    try {
      final response = await _dio.get(
        'https://www.tiktok.com/oembed',
        queryParameters: {'url': url},
      );

      final data = response.data;
      return EmbedMetadata(
        provider: 'TikTok',
        url: url,
        title: data['title'],
        authorName: data['author_name'],
        authorUrl: data['author_url'],
        thumbnailUrl: data['thumbnail_url'],
      );
    } catch (e) {
      log('TikTok oEmbed error: $e');
      return null;
    }
  }

  @visibleForTesting
  EmbedMetadata parseTumblr(String url) {
    final uri = Uri.tryParse(url);
    String? blogName;
    if (uri != null) {
      // URLs like tumblr.com/blogname/post/... or blogname.tumblr.com/post/...
      if (uri.host.endsWith('.tumblr.com')) {
        blogName = uri.host.replaceAll('.tumblr.com', '');
      } else if (uri.pathSegments.isNotEmpty) {
        blogName = uri.pathSegments.first;
      }
    }

    return EmbedMetadata(
      provider: 'Tumblr',
      url: url,
      title: blogName != null ? 'Tumblr post by $blogName' : 'Tumblr Post',
      authorName: blogName,
    );
  }

  @visibleForTesting
  EmbedMetadata parseMastodon(String url) {
    final uri = Uri.tryParse(url);
    String? username;
    String? instance;
    if (uri != null) {
      instance = uri.host;
      // URLs like mastodon.social/@username/123456
      for (final segment in uri.pathSegments) {
        if (segment.startsWith('@')) {
          username = segment;
          break;
        }
      }
    }

    return EmbedMetadata(
      provider: 'Mastodon',
      url: url,
      title: username != null ? '$username on $instance' : 'Mastodon Post',
      authorName: username,
    );
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}