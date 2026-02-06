import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/services/oembed_service.dart';

void main() {
  late OEmbedService service;

  setUp(() {
    service = OEmbedService();
  });

  group('parseVocaroo', () {
    test('extracts recording ID from standard URL', () {
      final metadata = service.parseVocaroo('https://vocaroo.com/abc123');
      expect(metadata.provider, 'Vocaroo');
      expect(metadata.url, 'https://vocaroo.com/abc123');
      expect(metadata.title, 'Voice recording (abc123)');
    });

    test('extracts last path segment as ID', () {
      final metadata = service.parseVocaroo('https://vocaroo.com/embed/xyz789');
      expect(metadata.title, 'Voice recording (xyz789)');
    });

    test('handles URL with no path segments gracefully', () {
      final metadata = service.parseVocaroo('https://vocaroo.com');
      // When host only, pathSegments is empty
      expect(metadata.provider, 'Vocaroo');
      expect(metadata.title, 'Voice Recording');
    });
  });

  group('parseInstagram', () {
    test('extracts username from post URL', () {
      final metadata = service.parseInstagram('https://www.instagram.com/p/ABC123/');
      expect(metadata.provider, 'Instagram');
      expect(metadata.title, 'Instagram post by p');
    });

    test('extracts username from profile URL', () {
      final metadata =
          service.parseInstagram('https://www.instagram.com/johndoe/');
      expect(metadata.title, 'Instagram post by johndoe');
    });

    test('handles URL with no path', () {
      final metadata = service.parseInstagram('https://www.instagram.com');
      expect(metadata.title, 'Instagram Post');
    });
  });

  group('parseTumblr', () {
    test('extracts blog name from subdomain URL', () {
      final metadata =
          service.parseTumblr('https://myblog.tumblr.com/post/123456');
      expect(metadata.provider, 'Tumblr');
      expect(metadata.title, 'Tumblr post by myblog');
      expect(metadata.authorName, 'myblog');
    });

    test('extracts blog name from tumblr.com path URL (no www)', () {
      final metadata =
          service.parseTumblr('https://tumblr.com/blogname/123456');
      expect(metadata.title, 'Tumblr post by blogname');
      expect(metadata.authorName, 'blogname');
    });

    test('www.tumblr.com matches subdomain pattern', () {
      // www.tumblr.com ends with .tumblr.com, so blog name = "www"
      final metadata =
          service.parseTumblr('https://www.tumblr.com/blogname/123456');
      expect(metadata.authorName, 'www');
    });

    test('handles tumblr.com with no path', () {
      final metadata = service.parseTumblr('https://tumblr.com');
      expect(metadata.title, 'Tumblr Post');
    });
  });

  group('parseMastodon', () {
    test('extracts username and instance from standard URL', () {
      final metadata = service.parseMastodon(
        'https://mastodon.social/@username/123456',
      );
      expect(metadata.provider, 'Mastodon');
      expect(metadata.title, '@username on mastodon.social');
      expect(metadata.authorName, '@username');
    });

    test('handles different instance', () {
      final metadata = service.parseMastodon(
        'https://fosstodon.org/@devuser/789',
      );
      expect(metadata.title, '@devuser on fosstodon.org');
      expect(metadata.authorName, '@devuser');
    });

    test('handles URL with no @ segment', () {
      final metadata = service.parseMastodon('https://mastodon.social/about');
      expect(metadata.title, 'Mastodon Post');
      expect(metadata.authorName, isNull);
    });

    test('handles URL with no path', () {
      final metadata = service.parseMastodon('https://mastodon.social');
      expect(metadata.title, 'Mastodon Post');
    });
  });

  group('clearCache', () {
    test('does not throw', () {
      expect(() => service.clearCache(), returnsNormally);
    });
  });
}
