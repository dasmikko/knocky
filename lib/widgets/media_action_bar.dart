import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Bottom action bar for media viewers (images and videos).
/// Provides share, download, and copy URL functionality.
/// Styled to match the BottomPaginator design.
class MediaActionBar extends StatefulWidget {
  /// The URL of the media to act on.
  final String url;

  /// Whether this is a video (affects download behavior).
  final bool isVideo;

  static const double barHeight = 60.0;

  const MediaActionBar({
    super.key,
    required this.url,
    this.isVideo = false,
  });

  /// Returns the height needed for bottom padding in layouts.
  static double getBottomPadding(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return barHeight + bottomSafeArea + 16;
  }

  @override
  State<MediaActionBar> createState() => _MediaActionBarState();
}

class _MediaActionBarState extends State<MediaActionBar> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _copyUrl() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(text: widget.url));
  }

  Future<void> _download() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Get the downloads directory
      final directory = await getApplicationDocumentsDirectory();

      // Extract filename from URL
      final uri = Uri.parse(widget.url);
      final filename = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'media_${DateTime.now().millisecondsSinceEpoch}';

      final filePath = '${directory.path}/$filename';

      // Download using Dio
      final dio = Dio();
      await dio.download(
        widget.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (!mounted) return;

      // Share the downloaded file so user can save it to their preferred location
      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));

      // Clean up the temp file
      try {
        await File(filePath).delete();
      } catch (_) {
        // Ignore cleanup errors
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download complete'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomSafeArea),
            child: Container(
              height: MediaActionBar.barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.copy,
                    label: 'Copy URL',
                    onPressed: _copyUrl,
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onPressed: _share,
                  ),
                  _buildDownloadButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: label,
    );
  }

  Widget _buildDownloadButton() {
    if (_isDownloading) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: _downloadProgress > 0 ? _downloadProgress : null,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _download,
      icon: const Icon(Icons.download),
      tooltip: 'Download',
    );
  }
}
