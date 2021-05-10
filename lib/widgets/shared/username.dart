import 'package:flutter/material.dart';
import 'package:knocky/helpers/usergroup.dart';

class Username extends StatelessWidget {
  final String username;
  final int usergroup;

  Username({@required this.username, @required this.usergroup});

  @override
  Widget build(BuildContext context) {
    return Text(username, style: TextStyle(color: getUserNameColor()));
  }

  Color getUserNameColor() {
    Usergroup group = Usergroup.values[usergroup];
    switch (group) {
      case Usergroup.banned:
        return Colors.red;
      case Usergroup.regular:
        return Colors.blue;
      case Usergroup.gold:
        return Colors.yellow;
      case Usergroup.moderator:
        return Colors.purpleAccent;
      case Usergroup.admin:
        return Colors.purpleAccent;
      case Usergroup.staff:
        return Colors.yellow;
      case Usergroup.moderatorInTraining:
        return Colors.purpleAccent;
      default:
        return Colors.blue;
    }
  }
}
