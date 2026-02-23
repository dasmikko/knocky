import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:google_fonts/google_fonts.dart';

import 'parser.dart';
import 'tags.dart';

const double bbcodeFontSize = 14;

BBStylesheet buildBBCodeStylesheet(
  BuildContext context, {
  required Function(String) onUrlTap,
  void Function(String url, String heroTag)? onImageTap,
  void Function(String url)? onVideoTap,
  void Function(int threadId, int page, int? postId)? onQuoteTap,
  void Function(int userId)? onMentionTap,
  List<dynamic> mentionUsers = const [],
  int? postId,
  String? heroTagPrefix,
  Widget Function(String content)? contentBuilder,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final prefix = heroTagPrefix ?? 'image_$postId';

  // Build mention user lookup map
  final mentionUserMap = <int, Map<String, dynamic>>{};
  for (final user in mentionUsers) {
    if (user is Map<String, dynamic>) {
      final id = user['id'] as int?;
      if (id != null) mentionUserMap[id] = user;
    }
  }

  final textColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white : Colors.black);
  final listNumberStyle = ListItemStyle(
    "%index%. ",
    TextStyle(color: textColor, fontWeight: FontWeight.bold),
  );
  final listBulletStyle = ListItemStyle(
    "\u2022 ",
    TextStyle(color: textColor, fontWeight: FontWeight.bold),
  );

  final stylesheet = defaultBBStylesheet(
    textStyle: GoogleFonts.openSans(
      fontSize: bbcodeFontSize,
      color: textColor,
    ),
  )
    // Replace default tags with customised versions
    ..replaceTag(UrlTag(onTap: onUrlTap))
    ..replaceTag(KnockoutImgTag(onTap: onImageTap, heroTagPrefix: prefix))
    ..replaceTag(KnockoutQuoteTag(isDark: isDark, onQuoteTap: onQuoteTap, contentBuilder: contentBuilder))
    ..replaceTag(KnockoutSpoilerTag(isDark: isDark, contentBuilder: contentBuilder))
    ..replaceTag(ListTag(listNumberStyle, listBulletStyle))
    ..replaceTag(OrderedList(listNumberStyle))
    ..replaceTag(UnorderedList(listBulletStyle))
    ..replaceTag(HeaderTag(1, 22))
    ..replaceTag(HeaderTag(2, 20))
    ..replaceTag(HeaderTag(3, 18))
    ..replaceTag(HeaderTag(4, 16))
    ..replaceTag(HeaderTag(5, 15))
    ..replaceTag(HeaderTag(6, 14))
    // Add new custom tags
    ..addTag(InlineCodeTag(isDark: isDark))
    ..addTag(EmoteTag(isDark: isDark))
    ..addTag(MentionTag(
      mentionUserMap: mentionUserMap,
      brightness: theme.brightness,
      onTap: onMentionTap,
    ))
    ..addTag(KnockoutVideoTag(onTap: onVideoTap))
    ..addTag(CodeBlockTag(isDark: isDark))
    ..addTag(SmartUrlTag())
    ..addTag(BlockquoteTag(contentBuilder: contentBuilder))
    ..addTag(KnockoutCollapseTag(isDark: isDark, contentBuilder: contentBuilder));

  // Register a LinkEmbedTag for each link provider (youtube, twitter, etc.)
  for (final entry in linkTags.entries) {
    stylesheet.addTag(
      LinkEmbedTag(tag: entry.key, provider: entry.key),
    );
  }

  return stylesheet;
}

String stripAllBBCode(String text) {
  return text
      .replaceAll(RegExp(r'\[/?[^\]]+\]'), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
