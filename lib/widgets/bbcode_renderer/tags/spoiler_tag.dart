import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:google_fonts/google_fonts.dart';

import '../parser.dart' show nodesToBBCode;
import '../stylesheet.dart' show bbcodeFontSize;

/// [spoiler]...[/spoiler] — tap-to-reveal spoiler.
///
/// Two modes matching the frontend (SpoilerBB.jsx):
/// - **Inline**: plain text hidden by matching text color to background.
/// - **Block**: rich content hidden behind a colored overlay.
class KnockoutSpoilerTag extends AdvancedTag {
  final bool isDark;
  final Widget Function(String content)? contentBuilder;

  KnockoutSpoilerTag({required this.isDark, this.contentBuilder})
    : super('spoiler');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final isInline = element.children.every((c) => c is bbob.Text);
    final innerContent = nodesToBBCode(element.children);

    if (isInline) {
      // Plain text — render inline, hidden via color matching.
      final text = element.children.map((c) => c.textContent).join();

      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _InlineSpoiler(
            text: text,
            isDark: isDark,
            style: renderer.getCurrentStyle(),
          ),
        ),
      ];
    }

    // Block content — overlay to hide, tap to reveal.
    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _BlockSpoiler(
            isDark: isDark,
            child: contentBuilder?.call(innerContent) ?? Text(innerContent),
          ),
        ),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Inline spoiler: text hidden by matching foreground to background color.
// ---------------------------------------------------------------------------

class _InlineSpoiler extends StatefulWidget {
  final String text;
  final bool isDark;
  final TextStyle? style;

  const _InlineSpoiler({required this.text, required this.isDark, this.style});

  @override
  State<_InlineSpoiler> createState() => _InlineSpoilerState();
}

class _InlineSpoilerState extends State<_InlineSpoiler> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hiddenColor =
        theme.textTheme.bodyMedium?.color ??
        (widget.isDark ? Colors.white : Colors.black);

    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _revealed ? Colors.transparent : hiddenColor,
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          widget.text,
          style: GoogleFonts.openSans(
            fontSize: bbcodeFontSize,
            color: _revealed
                ? (widget.style?.color ?? hiddenColor)
                : hiddenColor,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Block spoiler: rich content hidden behind a colored overlay.
// ---------------------------------------------------------------------------

class _BlockSpoiler extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const _BlockSpoiler({required this.isDark, required this.child});

  @override
  State<_BlockSpoiler> createState() => _BlockSpoilerState();
}

class _BlockSpoilerState extends State<_BlockSpoiler> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = widget.isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFD0D0D0);

    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Content — always rendered so it takes up its natural size.
            IgnorePointer(ignoring: !_revealed, child: widget.child),
            // Overlay — hides content when unrevealed.
            if (!_revealed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: overlayColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_off,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to reveal spoiler',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
