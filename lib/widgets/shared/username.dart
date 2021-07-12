import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/usergroup.dart';

class Username extends StatelessWidget {
  final String username;
  final Usergroup usergroup;
  final bool bold;
  final Function onClick;

  Username(
      {@required this.username,
      @required this.usergroup,
      this.bold,
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onClick,
        child: Text(username,
            style: TextStyle(
                color: AppColors(context).userGroupToColor(usergroup),
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)));
  }
}
