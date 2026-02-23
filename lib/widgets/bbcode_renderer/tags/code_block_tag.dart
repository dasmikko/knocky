import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:knocky/widgets/bbcode_renderer/stylesheet.dart';

/// [code]...[/code] — syntax-highlighted code block.
class CodeBlockTag extends AdvancedTag {
  final bool isDark;

  CodeBlockTag({required this.isDark}) : super('code');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final highlightTheme = isDark ? atomOneDarkTheme : atomOneLightTheme;
    final bgColor = highlightTheme['root']?.backgroundColor ??
        (isDark ? const Color(0xFF282c34) : const Color(0xFFFAFAFA));
    final borderColor =
        isDark ? const Color(0xFF2D2D44) : const Color(0xFFE0E0E0);

    // Extract raw text content, stripping any nested BBCode
    final codeContent = element.children
        .map((c) => c.textContent)
        .join()
        .replaceAll(RegExp(r'\[/?[^\]]+\]'), '')
        .trim();

    final language = element.attributes.isNotEmpty
        ? element.attributes.keys.first
        : null;
    final headerLabel = language != null ? 'Code \u2014 $language' : 'Code';

    // Parse and highlight
    final result = language != null
        ? highlight.parse(codeContent, language: language)
        : highlight.parse(codeContent, autoDetection: true);
    final spans = _convertHighlightNodes(result.nodes ?? [], highlightTheme);

    final textStyle = GoogleFonts.sourceCodePro(
      fontSize: bbcodeFontSize-2,
      color: highlightTheme['root']?.color ??
          (isDark ? const Color(0xFFABB2BF) : const Color(0xFF383A42)),
      height: 1.4,
    );

    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bar
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5)),
                  ),
                  child: Builder(builder: (context) {
                    return Row(
                      children: [
                        Icon(Icons.code, size: 14,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color),
                        const SizedBox(width: 6),
                        Text(
                          headerLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  }),
                ),
                // Code content
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: SelectableText.rich(
                    TextSpan(style: textStyle, children: spans),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  static List<TextSpan> _convertHighlightNodes(
    List<Node> nodes,
    Map<String, TextStyle> theme,
  ) {
    final spans = <TextSpan>[];
    for (final node in nodes) {
      _traverseNode(node, theme, spans);
    }
    return spans;
  }

  static void _traverseNode(
    Node node,
    Map<String, TextStyle> theme,
    List<TextSpan> spans,
  ) {
    if (node.value != null) {
      spans.add(TextSpan(
        text: node.value,
        style: node.className != null ? theme[node.className!] : null,
      ));
    } else if (node.children != null) {
      final childSpans = <TextSpan>[];
      for (final child in node.children!) {
        _traverseNode(child, theme, childSpans);
      }
      spans.add(TextSpan(
        children: childSpans,
        style: node.className != null ? theme[node.className!] : null,
      ));
    }
  }
}
