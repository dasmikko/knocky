import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import '../parser.dart' show nodesToBBCode;

/// [collapse title="..."]...[/collapse] — collapsible section.
class KnockoutCollapseTag extends AdvancedTag {
  final bool isDark;
  final Widget Function(String content)? contentBuilder;

  KnockoutCollapseTag({required this.isDark, this.contentBuilder})
      : super('collapse');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final title = element.attributes.isNotEmpty
        ? element.attributes.values.first
        : 'Collapsed';

    final bgColor =
        isDark ? const Color(0xFF3A4A5C) : const Color(0xFFD0D0D0);
    final borderColor =
        isDark ? const Color(0xFF1E2E3E) : const Color(0xFF999999);
    final innerContent = nodesToBBCode(element.children);

    return [
      WidgetSpan(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _CollapseWidget(
            title: title,
            backgroundColor: bgColor,
            borderColor: borderColor,
            child: contentBuilder?.call(innerContent) ??
                Text(innerContent),
          ),
        ),
      ),
    ];
  }
}

class _CollapseWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  const _CollapseWidget({
    required this.title,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  State<_CollapseWidget> createState() => _CollapseWidgetState();
}

class _CollapseWidgetState extends State<_CollapseWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
