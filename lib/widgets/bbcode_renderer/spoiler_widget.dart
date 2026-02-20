import 'package:flutter/material.dart';

/// A tappable spoiler widget that reveals content when tapped
class BbcodeSpoiler extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;

  const BbcodeSpoiler({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  @override
  State<BbcodeSpoiler> createState() => _BbcodeSpoilerState();
}

class _BbcodeSpoilerState extends State<BbcodeSpoiler>
    with SingleTickerProviderStateMixin {
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
                  AnimatedRotation(
                    turns: _isRevealed ? 0.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isRevealed ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
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
