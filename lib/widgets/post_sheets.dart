import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/knockout_api_service.dart';
import '../services/settings_service.dart';
import 'bbcode_editor/bbcode_editor.dart';

/// A bottom sheet for creating a new post in a thread.
class CreatePostSheet extends StatefulWidget {
  final BbcodeEditorController editorController;
  final int threadId;
  final KnockoutApiService apiService;
  final SettingsService settingsService;
  final String? initialContent;

  const CreatePostSheet({
    super.key,
    required this.editorController,
    required this.threadId,
    required this.apiService,
    required this.settingsService,
    this.initialContent,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    final content = widget.editorController.bbcode.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await widget.apiService.createPost(
      threadId: widget.threadId,
      content: content,
      displayCountryInfo: widget.settingsService.showCountryFlags,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to create post')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            AppBar(
              title: const Text('New Post'),
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _isSubmitting ? null : _submitPost,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const FaIcon(FontAwesomeIcons.paperPlane, size: 16),
                    label: const Text('Post'),
                  ),
                ),
              ],
            ),

            // Editor - adapts to available space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: BbcodeEditor(
                  controller: widget.editorController,
                  initialContent: widget.initialContent,
                  hintText: 'Write your reply...',
                  minHeight: 150,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bottom sheet for editing an existing post.
class EditPostSheet extends StatefulWidget {
  final BbcodeEditorController editorController;
  final int postId;
  final String initialContent;
  final KnockoutApiService apiService;

  const EditPostSheet({
    super.key,
    required this.editorController,
    required this.postId,
    required this.initialContent,
    required this.apiService,
  });

  @override
  State<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<EditPostSheet> {
  bool _isSubmitting = false;

  Future<void> _submitEdit() async {
    final content = widget.editorController.bbcode.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post content cannot be empty')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await widget.apiService.editPost(widget.postId, content);

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to edit post')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            AppBar(
              title: const Text('Edit Post'),
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submitEdit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const FaIcon(FontAwesomeIcons.floppyDisk, size: 16),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),

            // Editor - adapts to available space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: BbcodeEditor(
                  controller: widget.editorController,
                  initialContent: widget.initialContent,
                  hintText: 'Edit your post...',
                  minHeight: 150,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Strips existing [quote] tags from content to prevent quote pyramids.
String stripQuotes(String content) {
  // Remove all quote blocks with their content
  var result = content;
  final quotePattern = RegExp(
    r'\[quote[^\]]*\].*?\[/quote\]',
    caseSensitive: false,
    dotAll: true,
  );

  // Keep removing quotes until none left (handles nested quotes)
  while (quotePattern.hasMatch(result)) {
    result = result.replaceAll(quotePattern, '');
  }

  // Clean up extra whitespace
  result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  return result;
}
