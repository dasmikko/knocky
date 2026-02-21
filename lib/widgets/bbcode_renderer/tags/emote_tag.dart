import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import '../../../data/emotes.dart';

/// [emote=code][/emote] — renders an emote image from assets.
class EmoteTag extends AdvancedTag {
  final bool isDark;

  EmoteTag({required this.isDark}) : super('emote');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final code = element.attributes.isNotEmpty
        ? element.attributes.keys.first
        : null;
    if (code == null) return [];

    final emote = emoteMap[code];
    if (emote == null) {
      return [TextSpan(text: ':$code:', style: renderer.getCurrentStyle())];
    }

    final assetPath = (isDark && emote.assetPathDark != null)
        ? emote.assetPathDark!
        : emote.assetPath;

    return [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Tooltip(
          message: emote.title ?? ':${emote.code}:',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              height: 18,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
