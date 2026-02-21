import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../screens/image_viewer_screen.dart';
import '../../screens/thread_screen.dart';
import '../../screens/user_screen.dart';
import '../../screens/video_player_screen.dart';
import '../../services/deep_link_service.dart';
import 'parser.dart';
import 'stylesheet.dart';


class BbcodeRenderer extends StatelessWidget {
  final String content;
  final int? postId;
  final List<dynamic> mentionUsers;
  final String? heroTagPrefix;

  const BbcodeRenderer({
    super.key,
    required this.content,
    this.postId,
    this.mentionUsers = const [],
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final processed = preprocessContent(content);

    final stylesheet = buildBBCodeStylesheet(
      context,
      onUrlTap: _launchUrl,
      onImageTap: (url, heroTag) => _openImage(context, url, heroTag),
      onVideoTap: (url) => _openVideo(context, url),
      onQuoteTap: (threadId, page, postId) =>
          _openQuote(context, threadId, page, postId),
      onMentionTap: (userId) => _openUser(context, userId),
      mentionUsers: mentionUsers,
      postId: postId,
      heroTagPrefix: heroTagPrefix,
    );

    return BBCodeText(
      data: processed,
      stylesheet: stylesheet,
      errorBuilder: (context, error, stack) => SelectableText(
        stripAllBBCode(processed),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  /*
    Navigation callbacks
  */

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final route = DeepLinkService.parseUri(uri);
    if (route != null) {
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => route));
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openImage(BuildContext context, String url, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(url: url, heroTag: heroTag),
      ),
    );
  }

  void _openVideo(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(url: url)),
    );
  }

  void _openQuote(
      BuildContext context, int threadId, int page, int? postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThreadScreen(
          threadId: threadId,
          threadTitle: '',
          page: page,
          scrollToPostId: postId,
        ),
      ),
    );
  }

  void _openUser(BuildContext context, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserScreen(userId: userId)),
    );
  }
}
