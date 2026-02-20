import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

BBStylesheet buildBBCodeStylesheet(
  BuildContext context, {
  required Function(String) onUrlTap,
}) {
  final theme = Theme.of(context);
  return defaultBBStylesheet(
      textStyle: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodyMedium?.color,
      ),
    )
    ..replaceTag(UrlTag(onTap: onUrlTap))
    ..replaceTag(HeaderTag(1, 22)) // h1
    ..replaceTag(HeaderTag(2, 20)) // h2
    ..replaceTag(HeaderTag(3, 18)) // h3
    ..replaceTag(HeaderTag(4, 16)) // h4
    ..replaceTag(HeaderTag(5, 15)) // h5
    ..replaceTag(HeaderTag(6, 14)); // h6
}

String stripAllBBCode(String text) {
  return text
      .replaceAll(RegExp(r'\[/?[^\]]+\]'), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
