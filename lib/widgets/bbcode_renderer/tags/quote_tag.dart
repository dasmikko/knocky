import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

/// [quote username="..." threadId="..." threadPage="..." postId="..."]...[/quote]
class KnockoutQuoteTag extends WrappedStyleTag {
  final bool isDark;
  final void Function(int threadId, int page, int? postId)? onQuoteTap;

  KnockoutQuoteTag({required this.isDark, this.onQuoteTap}) : super('quote');

  @override
  List<InlineSpan> wrap(
    FlutterRenderer renderer,
    bbob.Element element,
    List<InlineSpan> spans,
  ) {
    final attrs = element.attributes;
    final username = attrs['username'] ?? 'Quote';
    final threadId = int.tryParse(attrs['threadId'] ?? '');
    final threadPage = int.tryParse(attrs['threadPage'] ?? '');
    final quotedPostId = int.tryParse(attrs['postId'] ?? '');
    final canNavigate = threadId != null && threadPage != null;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: canNavigate && onQuoteTap != null
                        ? () =>
                            onQuoteTap!(threadId, threadPage, quotedPostId)
                        : null,
                    child: Text(
                      '$username posted:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        decoration:
                            canNavigate ? TextDecoration.underline : null,
                        decorationColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(children: spans),
                    textScaler: MediaQuery.of(context).textScaler,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ];
  }
}
