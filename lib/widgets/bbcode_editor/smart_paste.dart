import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The type of content detected in a pasted URL
enum PasteUrlType {
  youtube('YouTube', FontAwesomeIcons.youtube, Colors.red),
  vimeo('Vimeo', FontAwesomeIcons.vimeo, Color(0xFF1AB7EA)),
  streamable('Streamable', Icons.stream, Color(0xFF0F90FA)),
  vocaroo('Vocaroo', Icons.mic, Color(0xFF4CAF50)),
  spotify('Spotify', Icons.music_note, Color(0xFF1DB954)),
  soundcloud('SoundCloud', FontAwesomeIcons.soundcloud, Color(0xFFFF5500)),
  twitter('Twitter/X', FontAwesomeIcons.twitter, Color(0xFF1DA1F2)),
  reddit('Reddit', FontAwesomeIcons.reddit, Colors.deepOrange),
  twitch('Twitch', FontAwesomeIcons.twitch, Colors.purple),
  bluesky('Bluesky', FontAwesomeIcons.bluesky, Color(0xFF0085FF)),
  instagram('Instagram', FontAwesomeIcons.instagram, Color(0xFFE1306C)),
  tiktok('TikTok', FontAwesomeIcons.tiktok, Colors.black),
  tumblr('Tumblr', FontAwesomeIcons.tumblr, Color(0xFF35465C)),
  mastodon('Mastodon', FontAwesomeIcons.mastodon, Color(0xFF6364FF)),
  image('Image', Icons.image, Color(0xFF4CAF50)),
  video('Video', Icons.videocam, Color(0xFF2196F3)),
  genericUrl('Link', Icons.link, Color(0xFF757575));

  final String label;
  final IconData icon;
  final Color color;

  const PasteUrlType(this.label, this.icon, this.color);

  /// The BBCode tag name for embed types
  String? get tagName => switch (this) {
        youtube => 'youtube',
        vimeo => 'vimeo',
        streamable => 'streamable',
        vocaroo => 'vocaroo',
        spotify => 'spotify',
        soundcloud => 'soundcloud',
        twitter => 'twitter',
        reddit => 'reddit',
        twitch => 'twitch',
        bluesky => 'bluesky',
        instagram => 'instagram',
        tiktok => 'tiktok',
        tumblr => 'tumblr',
        mastodon => 'mastodon',
        _ => null,
      };
}

/// What the user chose to do with the pasted URL
enum SmartPasteAction {
  embed, // Insert as the detected embed type
  link, // Insert as [url]
  smartLink, // Insert as [url smart]
  image, // Insert as [img]
  video, // Insert as [video]
  plainText, // Just paste the raw text
}

class SmartPasteResult {
  final SmartPasteAction action;
  final String url;
  final PasteUrlType type;

  const SmartPasteResult({
    required this.action,
    required this.url,
    required this.type,
  });
}

/// Detects the type of URL from pasted text.
/// Returns null if the text is not a valid URL.
PasteUrlType? detectUrlType(String text) {
  final trimmed = text.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
    return null;
  }

  final host = uri.host.toLowerCase();

  // Video platforms
  if (host.endsWith('youtube.com') || host == 'youtu.be') {
    return PasteUrlType.youtube;
  }
  if (host.endsWith('vimeo.com')) return PasteUrlType.vimeo;
  if (host.endsWith('streamable.com')) return PasteUrlType.streamable;
  if (host.endsWith('twitch.tv')) return PasteUrlType.twitch;

  // Social platforms
  if (host.endsWith('twitter.com') || host.endsWith('x.com')) {
    return PasteUrlType.twitter;
  }
  if (host.endsWith('reddit.com')) return PasteUrlType.reddit;
  if (host.endsWith('bsky.app')) return PasteUrlType.bluesky;
  if (host.endsWith('instagram.com')) return PasteUrlType.instagram;
  if (host.endsWith('tiktok.com')) return PasteUrlType.tiktok;
  if (host.endsWith('tumblr.com')) return PasteUrlType.tumblr;

  // Audio platforms
  if (host.endsWith('vocaroo.com') || host == 'voca.ro') {
    return PasteUrlType.vocaroo;
  }
  if (host.endsWith('spotify.com')) return PasteUrlType.spotify;
  if (host.endsWith('soundcloud.com')) return PasteUrlType.soundcloud;

  // Mastodon — common instances
  if (host.endsWith('mastodon.social') ||
      host.endsWith('mastodon.online') ||
      host.endsWith('mstdn.social')) {
    return PasteUrlType.mastodon;
  }

  // Media by file extension
  final path = uri.path.toLowerCase();
  if (RegExp(r'\.(jpe?g|png|gif|webp|svg)$').hasMatch(path)) {
    return PasteUrlType.image;
  }
  if (RegExp(r'\.(mp4|webm|mov)$').hasMatch(path)) {
    return PasteUrlType.video;
  }

  return PasteUrlType.genericUrl;
}

/// Shows a dialog asking how to insert the detected URL.
Future<SmartPasteResult?> showSmartPasteDialog(
  BuildContext context, {
  required String url,
  required PasteUrlType type,
}) {
  return showDialog<SmartPasteResult>(
    context: context,
    builder: (context) => _SmartPasteDialog(url: url, type: type),
  );
}

class _SmartPasteDialog extends StatelessWidget {
  final String url;
  final PasteUrlType type;

  const _SmartPasteDialog({required this.url, required this.type});

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();

    return AlertDialog(
      title: const Text('Paste URL'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              url,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ...options.map(
              (option) => ListTile(
                leading: Icon(option.icon, color: option.color, size: 20),
                title: Text(option.label),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => Navigator.of(context).pop(
                  SmartPasteResult(action: option.action, url: url, type: type),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  List<_PasteOption> _buildOptions() {
    return switch (type) {
      PasteUrlType.image => [
          _PasteOption('Insert as image', Icons.image, Color(0xFF4CAF50), SmartPasteAction.image),
          _PasteOption('Insert as link', Icons.link, null, SmartPasteAction.link),
          _PasteOption('Paste as text', Icons.text_fields, null, SmartPasteAction.plainText),
        ],
      PasteUrlType.video => [
          _PasteOption('Insert as video', Icons.videocam, Color(0xFF2196F3), SmartPasteAction.video),
          _PasteOption('Insert as link', Icons.link, null, SmartPasteAction.link),
          _PasteOption('Paste as text', Icons.text_fields, null, SmartPasteAction.plainText),
        ],
      PasteUrlType.genericUrl => [
          _PasteOption('Insert as link', Icons.link, null, SmartPasteAction.link),
          _PasteOption('Insert as smart link', Icons.preview, null, SmartPasteAction.smartLink),
          _PasteOption('Paste as text', Icons.text_fields, null, SmartPasteAction.plainText),
        ],
      _ => [
          _PasteOption(
            'Insert as ${type.label} embed',
            type.icon,
            type.color,
            SmartPasteAction.embed,
          ),
          _PasteOption('Insert as link', Icons.link, null, SmartPasteAction.link),
          _PasteOption('Paste as text', Icons.text_fields, null, SmartPasteAction.plainText),
        ],
    };
  }
}

class _PasteOption {
  final String label;
  final IconData icon;
  final Color? color;
  final SmartPasteAction action;

  const _PasteOption(this.label, this.icon, this.color, this.action);
}

/// Reads the clipboard, detects if it's a URL, and either shows the smart paste
/// dialog or performs a normal paste.
///
/// Returns true if the paste was handled (either via dialog or normal paste),
/// false if the clipboard was empty.
Future<bool> handleSmartPaste(
  BuildContext context, {
  required TextEditingController controller,
  required FocusNode focusNode,
}) async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  if (data?.text == null || data!.text!.isEmpty) return false;

  final clipText = data.text!;
  final type = detectUrlType(clipText);

  if (type == null) {
    // Not a URL — perform normal paste
    _insertText(controller, clipText);
    return true;
  }

  if (!context.mounted) return false;

  final result = await showSmartPasteDialog(
    context,
    url: clipText.trim(),
    type: type,
  );

  if (result == null) return true; // Dialog dismissed, do nothing

  // Refocus the text field after the dialog closes
  focusNode.requestFocus();

  switch (result.action) {
    case SmartPasteAction.embed:
      final tag = result.type.tagName;
      if (tag != null) {
        _insertText(controller, '[$tag]${result.url}[/$tag]');
      }
    case SmartPasteAction.link:
      _insertText(controller, '[url href="${result.url}"][/url]');
    case SmartPasteAction.smartLink:
      _insertText(controller, '[url smart href="${result.url}"][/url]');
    case SmartPasteAction.image:
      _insertText(controller, '[img]${result.url}[/img]');
    case SmartPasteAction.video:
      _insertText(controller, '[video]${result.url}[/video]');
    case SmartPasteAction.plainText:
      _insertText(controller, result.url);
  }

  return true;
}

/// Inserts text at the current cursor position in the controller,
/// replacing any selection.
void _insertText(TextEditingController controller, String text) {
  final selection = controller.selection;
  final currentText = controller.text;

  if (!selection.isValid) {
    controller.text = currentText + text;
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    return;
  }

  final start = selection.start;
  final end = selection.end;
  final newText = currentText.substring(0, start) + text + currentText.substring(end);
  controller.text = newText;
  controller.selection = TextSelection.collapsed(offset: start + text.length);
}
