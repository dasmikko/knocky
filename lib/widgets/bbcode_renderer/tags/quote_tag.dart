import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import '../parser.dart' show nodesToBBCode;

/// [quote username="..." threadId="..." threadPage="..." postId="..."]...[/quote]
class KnockoutQuoteTag extends AdvancedTag {
  final bool isDark;
  final void Function(int threadId, int page, int? postId)? onQuoteTap;
  final Widget Function(String content)? contentBuilder;

  KnockoutQuoteTag({
    required this.isDark,
    this.onQuoteTap,
    this.contentBuilder,
  }) : super('quote');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final attrs = element.attributes;
    final username = attrs['username'] ?? 'Quote';
    final threadId = int.tryParse(attrs['threadId'] ?? '');
    final threadPage = int.tryParse(attrs['threadPage'] ?? '');
    final quotedPostId = int.tryParse(attrs['postId'] ?? '');
    final canNavigate = threadId != null && threadPage != null;
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
                  contentBuilder?.call(innerContent) ??
                      Text(innerContent),
                ],
              ),
            );
          }),
        ),
      ),
    ];
  }
}
