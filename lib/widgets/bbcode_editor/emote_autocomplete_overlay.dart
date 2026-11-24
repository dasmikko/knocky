import 'package:flutter/material.dart';
import '../../data/emotes.dart';

/// Popup list of emote suggestions shown while typing `:code` in the editor.
class EmoteAutocompleteOverlay extends StatefulWidget {
  final List<Emote> emotes;
  final int selectedIndex;
  final void Function(Emote emote) onEmoteSelected;

  /// Hard cap from the editor, so the list never runs past the screen edge or
  /// under the keyboard. Falls back to the natural height when null.
  final double? maxHeight;

  const EmoteAutocompleteOverlay({
    super.key,
    required this.emotes,
    required this.selectedIndex,
    required this.onEmoteSelected,
    this.maxHeight,
  });

  /// Height of a single suggestion row.
  static const double itemExtent = 34;

  /// Number of rows visible before the list starts scrolling.
  static const int visibleItems = 4;

  /// Smallest useful height - below this the editor hides the list instead.
  static const double minHeight = itemExtent * 2 + 2;

  /// Rendered height for a given number of suggestions, borders included.
  static double heightFor(int count) {
    final rows = count < visibleItems ? count : visibleItems;
    return rows * itemExtent + 2;
  }

  @override
  State<EmoteAutocompleteOverlay> createState() =>
      _EmoteAutocompleteOverlayState();
}

class _EmoteAutocompleteOverlayState extends State<EmoteAutocompleteOverlay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(EmoteAutocompleteOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollSelectionIntoView();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollSelectionIntoView() {
    if (!_scrollController.hasClients) return;

    const extent = EmoteAutocompleteOverlay.itemExtent;
    final itemStart = widget.selectedIndex * extent;
    final itemEnd = itemStart + extent;
    final viewStart = _scrollController.offset;
    final viewEnd = viewStart + _scrollController.position.viewportDimension;

    double? target;
    if (itemStart < viewStart) {
      target = itemStart;
    } else if (itemEnd > viewEnd) {
      target = itemEnd - _scrollController.position.viewportDimension;
    }
    if (target == null) return;

    _scrollController.jumpTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight ??
              EmoteAutocompleteOverlay.heightFor(widget.emotes.length),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemExtent: EmoteAutocompleteOverlay.itemExtent,
          itemCount: widget.emotes.length,
          itemBuilder: (context, index) {
            return _EmoteSuggestionTile(
              emote: widget.emotes[index],
              selected: index == widget.selectedIndex,
              onTap: () => widget.onEmoteSelected(widget.emotes[index]),
            );
          },
        ),
      ),
    );
  }
}

class _EmoteSuggestionTile extends StatelessWidget {
  final Emote emote;
  final bool selected;
  final VoidCallback onTap;

  const _EmoteSuggestionTile({
    required this.emote,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Image.asset(
                emote.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 10),
            // Flexible so a long code ellipsizes instead of overflowing.
            Flexible(
              flex: 3,
              child: Text(
                ':${emote.code}:',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (emote.title != null) ...[
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Text(
                  emote.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper class to manage emote autocomplete state
class EmoteAutocompleteManager {
  /// Emote code being typed, anchored at the end of the text before the cursor.
  static final RegExp _emotePattern = RegExp(r':([a-zA-Z0-9_]+)$');

  /// Characters a `:` may follow and still start an emote code. Anything else
  /// (letters, digits, a closing `:`) means the colon is part of regular text,
  /// e.g. `Note:something` or an already completed `:smile:`.
  static final RegExp _triggerBoundary = RegExp(r'''[\s\]>"']''');

  /// Longest code we bother searching for.
  static const int _maxQueryLength = 32;

  /// Maximum number of suggestions returned.
  static const int _maxSuggestions = 8;

  /// Cached because the search runs on every keystroke.
  static final List<Emote> _searchableEmotes = visibleEmotes;

  /// Check if the text before the cursor triggers autocomplete.
  /// Returns the search query (without the leading `:`) if triggered.
  static String? getEmoteQuery(String text, int cursorPosition) {
    final match = _matchTrigger(text, cursorPosition);
    return match?.group(1);
  }

  /// Get matching emotes for a query, prefix matches first.
  static List<Emote> getMatchingEmotes(String query) {
    if (query.isEmpty) return const [];

    final lowerQuery = query.toLowerCase();
    final prefixMatches = <Emote>[];
    final otherMatches = <Emote>[];

    for (final emote in _searchableEmotes) {
      final code = emote.code.toLowerCase();
      if (code.startsWith(lowerQuery)) {
        prefixMatches.add(emote);
      } else if (code.contains(lowerQuery) ||
          (emote.title?.toLowerCase().contains(lowerQuery) ?? false)) {
        otherMatches.add(emote);
      }
    }

    // Shortest prefix match is the most likely intent.
    prefixMatches.sort((a, b) => a.code.length.compareTo(b.code.length));

    return [
      ...prefixMatches,
      ...otherMatches,
    ].take(_maxSuggestions).toList();
  }

  /// Get the range to replace when inserting an emote.
  static (int start, int end) getReplaceRange(String text, int cursorPosition) {
    final match = _matchTrigger(text, cursorPosition);
    if (match != null) {
      return (match.start, cursorPosition);
    }
    return (cursorPosition, cursorPosition);
  }

  static RegExpMatch? _matchTrigger(String text, int cursorPosition) {
    if (cursorPosition <= 0 || cursorPosition > text.length) return null;

    final textBeforeCursor = text.substring(0, cursorPosition);
    final match = _emotePattern.firstMatch(textBeforeCursor);
    if (match == null) return null;

    if (match.group(1)!.length > _maxQueryLength) return null;

    // The `:` must start a word.
    if (match.start > 0 &&
        !_triggerBoundary.hasMatch(textBeforeCursor[match.start - 1])) {
      return null;
    }

    return match;
  }
}
