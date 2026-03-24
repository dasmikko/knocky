import 'package:flutter/material.dart';

/// Wraps quote content with a max height and expand/collapse toggle.
class CollapsibleQuoteBody extends StatefulWidget {
  const CollapsibleQuoteBody({
    super.key,
    required this.child,
    this.collapsedHeight = 200,
  });

  final Widget child;
  final double collapsedHeight;

  @override
  State<CollapsibleQuoteBody> createState() => _CollapsibleQuoteBodyState();
}

class _CollapsibleQuoteBodyState extends State<CollapsibleQuoteBody> {
  bool _expanded = false;
  bool? _overflows;
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted || _overflows != null) return;
    final box =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    setState(() => _overflows = box.size.height >= widget.collapsedHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overflows = _overflows ?? false;

    if (_overflows == false) {
      // Confirmed it doesn't overflow — render without constraint
      return KeyedSubtree(key: _childKey, child: widget.child);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_expanded)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.collapsedHeight),
            child: ClipRect(
              child: KeyedSubtree(key: _childKey, child: widget.child),
            ),
          )
        else
          KeyedSubtree(key: _childKey, child: widget.child),
        if (overflows)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.8),
              child: Icon(
                _expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
