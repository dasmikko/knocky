import 'dart:ui';

import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/v2/userRole.dart';

class UserRoleLabel extends StatelessWidget {
  final UserRole role;
  final bool banned;
  //final DateFormat joinFormat = new DateFormat('MMMM yyyy');

  UserRoleLabel({@required this.role, this.banned});

  Widget bannedLabel(BuildContext context) {
    return banned
        ? Text('Banned ',
            style: TextStyle(
                color: AppColors(context).bannedColor(),
                fontWeight: FontWeight.bold))
        : Container();
  }

  Widget userRoleLabel(BuildContext context) {
    print(role.toJson());
    switch (role.code) {
      case RoleCode.BASIC_USER:
        return Text(
          'Member',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        );
        break;
      case RoleCode.GOLD_USER:
      case RoleCode.PAID_GOLD_USER:
        return Text(
          'Gold member',
          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
        );
        break;
      case RoleCode.ADMIN:
        return Text(
          'Admin',
          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
        );
        break;
      case RoleCode.MODERATOR:
      case RoleCode.MODERATOR_IN_TRAINING:
      case RoleCode.SUPER_MODERATOR:
        return Text(
          'Moderator',
          style:
              TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold),
        );
        break;
      default:
        return Text(
          'Member',
          style: TextStyle(color: Colors.blue),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      bannedLabel(context),
      userRoleLabel(context),
    ]);
  }
}
