import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/usergroup.dart';

class Username extends StatelessWidget {
  final String username;
  final Usergroup usergroup;
  final bool bold;
  final Function onClick;
  final double fontSize;

  Username(
      {@required this.username,
      @required this.usergroup,
      this.bold,
      this.onClick,
      this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            padding:
                MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)),
        onPressed: onClick,
        child: Text(username,
            style: TextStyle(
                fontSize: fontSize,
                color: AppColors(context).userGroupToColor(usergroup),
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)));
  }
}
