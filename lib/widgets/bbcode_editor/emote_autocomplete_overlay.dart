import 'package:flutter/material.dart';
import '../../data/emotes.dart';

class EmoteAutocompleteOverlay extends StatelessWidget {
  final List<Emote> emotes;
  final void Function(Emote emote) onEmoteSelected;
  final VoidCallback onDismiss;

  const EmoteAutocompleteOverlay({
    super.key,
    required this.emotes,
    required this.onEmoteSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 200,
          maxWidth: 300,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: emotes.length,
          itemBuilder: (context, index) {
            final emote = emotes[index];
            return InkWell(
              onTap: () => onEmoteSelected(emote),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Image.asset(
                        emote.assetPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ':${emote.code}:',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (emote.title != null)
                      Text(
                        emote.title!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper class to manage emote autocomplete state
class EmoteAutocompleteManager {
  static final RegExp _emotePattern = RegExp(r':([a-zA-Z0-9_]*)$');

  /// Check if the text before cursor triggers autocomplete
  /// Returns the search query if triggered, null otherwise
  static String? getEmoteQuery(String text, int cursorPosition) {
    if (cursorPosition <= 0 || cursorPosition > text.length) return null;

    final textBeforeCursor = text.substring(0, cursorPosition);
    final match = _emotePattern.firstMatch(textBeforeCursor);

    if (match != null) {
      return match.group(1) ?? '';
    }
    return null;
  }

  /// Get matching emotes for a query
  static List<Emote> getMatchingEmotes(String query) {
    if (query.isEmpty) {
      // Show first few emotes when just `:` is typed
      return visibleEmotes.take(10).toList();
    }

    final lowerQuery = query.toLowerCase();
    return visibleEmotes
        .where((e) => e.code.toLowerCase().startsWith(lowerQuery))
        .take(10)
        .toList();
  }

  /// Get the range to replace when inserting an emote
  static (int start, int end) getReplaceRange(String text, int cursorPosition) {
    final textBeforeCursor = text.substring(0, cursorPosition);
    final match = _emotePattern.firstMatch(textBeforeCursor);

    if (match != null) {
      return (match.start, cursorPosition);
    }
    return (cursorPosition, cursorPosition);
  }
}
