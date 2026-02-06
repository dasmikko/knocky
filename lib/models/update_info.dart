/// Information about an available app update from GitHub releases.
class UpdateInfo {
  final String version;
  final String releaseName;
  final String body;
  final String downloadUrl;
  final String htmlUrl;

  UpdateInfo({
    required this.version,
    required this.releaseName,
    required this.body,
    required this.downloadUrl,
    required this.htmlUrl,
  });

  factory UpdateInfo.fromGitHubRelease(Map<String, dynamic> json) {
    // Find the first .apk asset, fall back to release page URL
    final assets = json['assets'] as List<dynamic>? ?? [];
    String apkUrl = '';
    for (final asset in assets) {
      final name = asset['name'] as String? ?? '';
      if (name.endsWith('.apk')) {
        apkUrl = asset['browser_download_url'] as String? ?? '';
        break;
      }
    }

    final tagName = json['tag_name'] as String? ?? '';

    return UpdateInfo(
      version: tagName.startsWith('v') ? tagName.substring(1) : tagName,
      releaseName: json['name'] as String? ?? tagName,
      body: json['body'] as String? ?? '',
      downloadUrl: apkUrl,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}
