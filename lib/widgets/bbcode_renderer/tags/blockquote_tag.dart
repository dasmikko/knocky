import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

/// [blockquote]...[/blockquote] — simple left-border quote.
class BlockquoteTag extends WrappedStyleTag {
  BlockquoteTag() : super('blockquote');

  @override
  List<InlineSpan> wrap(
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
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
              child: RichText(
                text: TextSpan(children: spans),
                textScaler: MediaQuery.of(context).textScaler,
              ),
            );
          }),
        ),
      ),
    ];
  }
}
