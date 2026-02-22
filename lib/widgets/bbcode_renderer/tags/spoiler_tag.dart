import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import '../parser.dart' show nodesToBBCode;

/// [spoiler]...[/spoiler] — tap-to-reveal spoiler.
class KnockoutSpoilerTag extends AdvancedTag {
  final bool isDark;
  final Widget Function(String content)? contentBuilder;

  KnockoutSpoilerTag({required this.isDark, this.contentBuilder})
      : super('spoiler');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final bgColor =
        isDark ? const Color(0xFF3A4A5C) : const Color(0xFFD0D0D0);
    final innerContent = nodesToBBCode(element.children);

    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SpoilerWidget(
            backgroundColor: bgColor,
            child: contentBuilder?.call(innerContent) ??
                Text(innerContent),
          ),
        ),
      ),
    ];
  }
}

class _SpoilerWidget extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;

  const _SpoilerWidget({
    required this.child,
    required this.backgroundColor,
  });

  @override
  State<_SpoilerWidget> createState() => _SpoilerWidgetState();
}

class _SpoilerWidgetState extends State<_SpoilerWidget> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => setState(() => _isRevealed = !_isRevealed),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isRevealed ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRevealed
                        ? 'Spoiler (tap to hide)'
                        : 'Spoiler (tap to reveal)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isRevealed ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.child,
                ),
                crossFadeState: _isRevealed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
