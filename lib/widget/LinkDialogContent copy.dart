import 'package:flutter/material.dart';

class LinkDialogWidget extends StatefulWidget {
  final Function onChanged;

  LinkDialogWidget({this.onChanged});

  @override
  _LinkDialogWidgetState createState() => _LinkDialogWidgetState();
}

class _LinkDialogWidgetState extends State<LinkDialogWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('Is rich link'),
      value: isSelected,
      onChanged: (value) {
        setState(() {
          isSelected = value;
        });
        this.widget.onChanged(value);
      },
    );
  }
}
