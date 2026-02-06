import 'package:flutter/material.dart';
import '../../../data/emotes.dart';

/// Shows a dialog to pick an emote with filtering
Future<Emote?> showEmotePickerDialog(BuildContext context) async {
  return showDialog<Emote>(
    context: context,
    builder: (context) => const EmotePickerDialog(),
  );
}

class EmotePickerDialog extends StatefulWidget {
  const EmotePickerDialog({super.key});

  @override
  State<EmotePickerDialog> createState() => _EmotePickerDialogState();
}

class _EmotePickerDialogState extends State<EmotePickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Emote> _filteredEmotes = [];

  @override
  void initState() {
    super.initState();
    _filteredEmotes = visibleEmotes;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEmotes = visibleEmotes;
      } else {
        _filteredEmotes = visibleEmotes
            .where((e) =>
                e.code.toLowerCase().contains(query) ||
                (e.title?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_emotions),
                      const SizedBox(width: 8),
                      const Text(
                        'Insert Emote',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search emotes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Emote grid
            Expanded(
              child: _filteredEmotes.isEmpty
                  ? const Center(
                      child: Text(
                        'No emotes found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: _filteredEmotes.length,
                      itemBuilder: (context, index) {
                        final emote = _filteredEmotes[index];
                        return _EmoteTile(
                          emote: emote,
                          onTap: () => Navigator.pop(context, emote),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmoteTile extends StatelessWidget {
  final Emote emote;
  final VoidCallback onTap;

  const _EmoteTile({
    required this.emote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: ':${emote.code}:',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).hoverColor,
          ),
          child: Image.asset(
            emote.assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
