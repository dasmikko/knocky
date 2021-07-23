import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/usergroup.dart';

class UsergroupLabel extends StatelessWidget {
  final Usergroup usergroup;
  final String extraText;

  UsergroupLabel({@required this.usergroup, this.extraText});

  Widget userGroupLabel(BuildContext context) {
    return Text(UsergroupHelper.userGroupToString(usergroup),
        style: TextStyle(
            color: AppColors(context).userGroupToColor(usergroup),
            fontWeight: FontWeight.bold));
  }

  Widget extraTextLabel(BuildContext context) {
    if (extraText != null) {
      return Text(" - $extraText");
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [userGroupLabel(context), extraTextLabel(context)]);
  }
}
