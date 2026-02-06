import 'package:flutter/material.dart';

/// Dialog result for quote input
class QuoteDialogResult {
  final String content;
  final String? username;

  QuoteDialogResult({required this.content, this.username});
}

/// Shows a dialog to input quote content and optional username
Future<QuoteDialogResult?> showQuoteDialog(BuildContext context, {String? initialContent}) {
  return showDialog<QuoteDialogResult>(
    context: context,
    builder: (context) => _QuoteDialog(initialContent: initialContent),
  );
}

class _QuoteDialog extends StatefulWidget {
  final String? initialContent;

  const _QuoteDialog({this.initialContent});

  @override
  State<_QuoteDialog> createState() => _QuoteDialogState();
}

class _QuoteDialogState extends State<_QuoteDialog> {
  late final TextEditingController _contentController;
  late final TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent ?? '');
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(QuoteDialogResult(
        content: _contentController.text.trim(),
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Quote'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (optional)',
                hintText: 'Who said this?',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Quote Content',
                hintText: 'Enter the quoted text...',
                prefixIcon: Icon(Icons.format_quote),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter quote content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
