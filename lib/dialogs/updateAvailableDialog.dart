import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UpdateAvailableDialog extends StatelessWidget {
  final String title;
  final String content;
  final String version;

  const UpdateAvailableDialog({
    this.title = ' is available!',
    this.content = '',
    this.version = 'N/A',
  }) : super();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.version + this.title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, minHeight: 100),
        child: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Markdown(data: this.content),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false), child: Text('Cancel')),
        TextButton(
            onPressed: () => Get.back(result: true), child: Text('Update')),
      ],
    );
  }
}
