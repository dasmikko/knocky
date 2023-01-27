import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputDialog extends StatefulWidget {
  final String title;
  final String content;

  const InputDialog({this.title = 'Enter your input', this.content = ''})
      : super();

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.content;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.widget.title),
      content: TextField(
        controller: _controller,
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false), child: Text('Cancel')),
        TextButton(
            onPressed: () => Get.back(result: _controller.text),
            child: Text('OK')),
      ],
    );
  }
}
