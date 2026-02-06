import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/models/update_info.dart';

void main() {
  group('UpdateInfo.fromGitHubRelease', () {
    test('parses full release with APK asset', () {
      final json = {
        'tag_name': 'v1.2.3',
        'name': 'Release 1.2.3',
        'body': 'Bug fixes and improvements',
        'html_url': 'https://github.com/dasmikko/knocky/releases/tag/v1.2.3',
        'assets': [
          {
            'name': 'knocky-1.2.3.apk',
            'browser_download_url':
                'https://github.com/dasmikko/knocky/releases/download/v1.2.3/knocky-1.2.3.apk',
          },
          {
            'name': 'checksums.txt',
            'browser_download_url':
                'https://github.com/dasmikko/knocky/releases/download/v1.2.3/checksums.txt',
          },
        ],
      };

      final info = UpdateInfo.fromGitHubRelease(json);

      expect(info.version, '1.2.3');
      expect(info.releaseName, 'Release 1.2.3');
      expect(info.body, 'Bug fixes and improvements');
      expect(info.htmlUrl, 'https://github.com/dasmikko/knocky/releases/tag/v1.2.3');
      expect(
        info.downloadUrl,
        'https://github.com/dasmikko/knocky/releases/download/v1.2.3/knocky-1.2.3.apk',
      );
    });

    test('strips v prefix from version tag', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': 'v2.0.0',
        'assets': [],
      });
      expect(info.version, '2.0.0');
    });

    test('handles version without v prefix', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': '3.1.0',
        'assets': [],
      });
      expect(info.version, '3.1.0');
    });

    test('falls back to empty downloadUrl when no APK asset', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': 'v1.0.0',
        'name': 'Release 1.0.0',
        'body': 'Some notes',
        'html_url': 'https://github.com/dasmikko/knocky/releases/tag/v1.0.0',
        'assets': [
          {'name': 'source.tar.gz', 'browser_download_url': 'https://example.com/source.tar.gz'},
        ],
      });
      expect(info.downloadUrl, '');
    });

    test('handles empty assets list', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': 'v1.0.0',
        'assets': [],
      });
      expect(info.downloadUrl, '');
    });

    test('handles null assets', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': 'v1.0.0',
      });
      expect(info.downloadUrl, '');
    });

    test('handles missing optional fields gracefully', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': 'v1.0.0',
      });
      expect(info.version, '1.0.0');
      expect(info.releaseName, 'v1.0.0'); // falls back to tag_name
      expect(info.body, '');
      expect(info.htmlUrl, '');
      expect(info.downloadUrl, '');
    });

    test('handles completely empty JSON', () {
      final info = UpdateInfo.fromGitHubRelease({});
      expect(info.version, '');
      expect(info.releaseName, '');
      expect(info.body, '');
    });

    test('picks first APK asset when multiple exist', () {
      final info = UpdateInfo.fromGitHubRelease({
        'tag_name': 'v1.0.0',
        'assets': [
          {'name': 'readme.txt', 'browser_download_url': 'https://example.com/readme.txt'},
          {'name': 'app-arm64.apk', 'browser_download_url': 'https://example.com/arm64.apk'},
          {'name': 'app-x86.apk', 'browser_download_url': 'https://example.com/x86.apk'},
        ],
      });
      expect(info.downloadUrl, 'https://example.com/arm64.apk');
    });
  });
}
