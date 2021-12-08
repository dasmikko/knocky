import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDialog({this.title = 'Are you sure', this.content = ''})
      : super();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.title),
      content: Text(this.content),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('No')),
        TextButton(onPressed: () => Get.back(result: true), child: Text('Yes')),
      ],
    );
  }
}
