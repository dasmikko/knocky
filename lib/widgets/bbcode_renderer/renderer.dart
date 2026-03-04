import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../screens/image_viewer_screen.dart';
import '../../screens/thread_screen.dart';
import '../../screens/user_screen.dart';
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
      onQuoteTap: (threadId, page, postId) =>
          _openQuote(context, threadId, page, postId),
      onMentionTap: (userId) => _openUser(context, userId),
      mentionUsers: mentionUsers,
      postId: postId,
      heroTagPrefix: heroTagPrefix,
      contentBuilder: (innerContent) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: BbcodeRenderer(
          content: innerContent,
          postId: postId,
          mentionUsers: mentionUsers,
          heroTagPrefix: heroTagPrefix,
        ),
      ),
    );

    // Parse BBCode ourselves to catch errors that BBCodeText doesn't handle
    // (e.g. RangeError from bbob_dart's trimChar on malformed attributes).
    List<InlineSpan> spans;
    try {
      spans = parseBBCode(processed, stylesheet: stylesheet);
    } catch (_) {
      return SelectableText(
        stripAllBBCode(processed),
        style: TextStyle(
          fontSize: bbcodeFontSize,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      );
    }

    final textScaler = MediaQuery.of(context).textScaler;
    return RichText(
      text: TextSpan(children: spans, style: stylesheet.defaultTextStyle),
      textScaler: textScaler,
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
