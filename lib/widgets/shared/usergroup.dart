import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/usergroup.dart';

class UsergroupLabel extends StatelessWidget {
  final Usergroup usergroup;
  final bool banned;
  final DateTime joinDate;
  //final DateFormat joinFormat = new DateFormat('MMMM yyyy');

  UsergroupLabel({@required this.usergroup, this.banned, this.joinDate});

  Widget userGroupLabel(BuildContext context) {
    return Text(UsergroupHelper.userGroupToString(usergroup),
        style: TextStyle(
            color:
                AppColors(context).userGroupToColor(usergroup, banned: banned),
            fontWeight: FontWeight.bold));
  }

  Widget bannedLabel(BuildContext context) {
    return banned
        ? Text('Banned ',
            style: TextStyle(
                color: AppColors(context).bannedColor(),
                fontWeight: FontWeight.bold))
        : Container();
  }

  Widget joinDateLabel() {
    //return Text(" - joined ${joinFormat.format(joinDate)}");
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      bannedLabel(context),
      userGroupLabel(context),
      joinDateLabel()
    ]);
  }
}
