import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import '../parser.dart' show nodesToBBCode;

/// [blockquote]...[/blockquote] — simple left-border quote.
class BlockquoteTag extends AdvancedTag {
  final Widget Function(String content)? contentBuilder;

  BlockquoteTag({this.contentBuilder}) : super('blockquote');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final innerContent = nodesToBBCode(element.children);

    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Builder(builder: (context) {
            final theme = Theme.of(context);
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left:
                      BorderSide(color: theme.colorScheme.primary, width: 3),
                ),
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.all(12),
              child: contentBuilder?.call(innerContent) ??
                  Text(innerContent),
            );
          }),
        ),
      ),
    ];
  }
}
