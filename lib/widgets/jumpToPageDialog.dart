import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

class JumpToPageDialog extends StatefulWidget {
  final int? minValue;
  final int? maxValue;
  final int? value;

  JumpToPageDialog({this.maxValue, this.minValue, this.value});

  @override
  _JumpToPageDialogState createState() => _JumpToPageDialogState();
}

class _JumpToPageDialogState extends State<JumpToPageDialog> {
  int? currentValue;

  @override
  void initState() {
    this.currentValue = this.widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Jump to page'),
      actions: [
        TextButton(
          child: Text('Go'),
          onPressed: () {
            Get.back(result: currentValue);
          },
        ),
      ],
      content: NumberPicker(
        maxValue: this.widget.maxValue!,
        minValue: this.widget.minValue!,
        value: this.currentValue!,
        onChanged: (int value) {
          setState(() {
            currentValue = value;
          });
        },
      ),
    );
  }
}
