import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import '../../data/emotes.dart';
import '../../data/role_colors.dart';
import '../../screens/user_screen.dart';
import 'stylesheet.dart';

/// Builds inline spans with emotes, mentions, and inline code.
class BBCodeInlineRenderer {
  final List<dynamic> mentionUsers;

  BBCodeInlineRenderer({required this.mentionUsers});

  // ==========================================================================
  // DETECTION
  // ==========================================================================

  static final _mentionPattern = RegExp(r'@<(\d+;?.*?)>');
  static final _inlineCodePattern =
      RegExp(r'\[icode\](.*?)\[/icode\]', caseSensitive: false);

  static bool _hasEmotes(String text) {
    return RegExp(r':([a-zA-Z0-9_]+):').hasMatch(text);
  }

  static bool _hasMentions(String text) {
    return _mentionPattern.hasMatch(text);
  }

  static bool _hasInlineCode(String text) {
    return _inlineCodePattern.hasMatch(text);
  }

  /// Returns true if the text contains emotes, mentions, or inline code
  /// that require the custom inline renderer instead of plain BBCodeText.
  static bool needsCustomRenderer(String text) {
    return _hasEmotes(text) || _hasMentions(text) || _hasInlineCode(text);
  }

  // ==========================================================================
  // RENDERING
  // ==========================================================================

  /// Build a widget that renders BBCode text with inline emotes, mentions, and code.
  Widget build(BuildContext context, String text, BBStylesheet stylesheet) {
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          lines.map((line) => _buildLine(context, line, stylesheet)).toList(),
    );
  }

  /// Build a single line with emotes, mentions, and inline code.
  Widget _buildLine(
    BuildContext context,
    String line,
    BBStylesheet stylesheet,
  ) {
    if (line.isEmpty) {
      return const SizedBox(height: 14);
    }

    final emotePattern = RegExp(r':([a-zA-Z0-9_]+):');

    // Check if any valid emotes exist in this line
    bool hasValidEmotes = false;
    for (final match in emotePattern.allMatches(line)) {
      if (emoteMap[match.group(1)!] != null) {
        hasValidEmotes = true;
        break;
      }
    }

    final hasMentions = _hasMentions(line);
    final hasInlineCode = _hasInlineCode(line);

    // If no valid emotes, no mentions, and no inline code, render as BBCode normally
    if (!hasValidEmotes && !hasMentions && !hasInlineCode) {
      return BBCodeText(
        data: line,
        stylesheet: stylesheet,
        errorBuilder: (context, error, stack) => Text(
          stripAllBBCode(line),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    // Build inline spans
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brightness = theme.brightness;
    final mentionUserMap = _buildMentionUserMap();

    // Combined pattern: emotes (:code:), mentions (@<id>), and inline code ([icode]...[/icode])
    final combinedPattern = RegExp(
      r'(:([a-zA-Z0-9_]+):)|(@<(\d+;?.*?)>)|(\[icode\](.*?)\[/icode\])',
      caseSensitive: false,
    );

    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in combinedPattern.allMatches(line)) {
      if (match.start > lastEnd) {
        final textBefore = line.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          spans.addAll(parseBBCode(textBefore, stylesheet: stylesheet));
        }
      }

      if (match.group(1) != null) {
        // Emote match
        final emoteCode = match.group(2)!;
        final emote = emoteMap[emoteCode];

        if (emote != null) {
          final emoteAssetPath = (isDark && emote.assetPathDark != null)
              ? emote.assetPathDark!
              : emote.assetPath;
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              message: emote.title ?? ':${emote.code}:',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  height: 18,
                  child: Image.asset(
                    emoteAssetPath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: match.group(0)!,
            style: stylesheet.defaultTextStyle,
          ));
        }
      } else if (match.group(3) != null) {
        // Mention match
        final mentionContent = match.group(4)!;
        final userId = int.tryParse(mentionContent.split(';')[0]);
        final user = userId != null ? mentionUserMap[userId] : null;

        if (user != null) {
          final username = user['username'] as String? ?? 'Unknown';
          final roleCode =
              (user['role'] as Map<String, dynamic>?)?['code'] as String?;
          final color = getRoleColor(roleCode, brightness: brightness);

          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserScreen(userId: userId!),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ));
        } else {
          // Unknown user — render raw text
          spans.add(TextSpan(
            text: match.group(0)!,
            style: stylesheet.defaultTextStyle,
          ));
        }
      } else if (match.group(5) != null) {
        // Inline code match
        final codeText = match.group(6) ?? '';
        final codeBg = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF5F5F5);
        final codeBorder = isDark
            ? const Color(0xFF2D2D44)
            : const Color(0xFFE0E0E0);
        final codeColor = isDark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF333333);

        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: codeBg,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: codeBorder, width: 1),
            ),
            child: Text(
              codeText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: codeColor,
              ),
            ),
          ),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      final remaining = line.substring(lastEnd);
      if (remaining.isNotEmpty) {
        spans.addAll(parseBBCode(remaining, stylesheet: stylesheet));
      }
    }

    return RichText(
      text: TextSpan(children: spans, style: stylesheet.defaultTextStyle),
      textScaler: MediaQuery.of(context).textScaler,
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Map<int, Map<String, dynamic>> _buildMentionUserMap() {
    final map = <int, Map<String, dynamic>>{};
    for (final user in mentionUsers) {
      if (user is Map<String, dynamic>) {
        final id = user['id'] as int?;
        if (id != null) {
          map[id] = user;
        }
      }
    }
    return map;
  }
}
