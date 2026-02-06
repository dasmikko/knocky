import 'package:flutter/material.dart';

/// Dialog result for URL input
class UrlDialogResult {
  final String url;
  final String? linkText;

  UrlDialogResult({required this.url, this.linkText});
}

/// Shows a dialog to input a URL and optional link text
Future<UrlDialogResult?> showUrlDialog(BuildContext context, {String? initialUrl, String? initialText}) {
  return showDialog<UrlDialogResult>(
    context: context,
    builder: (context) => _UrlDialog(initialUrl: initialUrl, initialText: initialText),
  );
}

class _UrlDialog extends StatefulWidget {
  final String? initialUrl;
  final String? initialText;

  const _UrlDialog({this.initialUrl, this.initialText});

  @override
  State<_UrlDialog> createState() => _UrlDialogState();
}

class _UrlDialogState extends State<_UrlDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(UrlDialogResult(
        url: _urlController.text.trim(),
        linkText: _textController.text.trim().isEmpty ? null : _textController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Link'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a URL';
                }
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasScheme) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Link Text (optional)',
                hintText: 'Click here',
                prefixIcon: Icon(Icons.text_fields),
              ),
              onFieldSubmitted: (_) => _submit(),
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
