import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

class Username extends StatelessWidget {
  final String username;
  final int usergroup;

  Username({@required this.username, @required this.usergroup});

  @override
  Widget build(BuildContext context) {
    return Text(username,
        style:
            TextStyle(color: AppColors(context).userGroupToColor(usergroup)));
  }
}
