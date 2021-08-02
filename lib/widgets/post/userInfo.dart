import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/screens/profile.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:knocky/widgets/shared/background.dart';
import 'package:knocky/widgets/shared/username.dart';

class UserInfo extends StatelessWidget {
  final ThreadPostUser user;

  UserInfo({@required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 64,
        child: Stack(fit: StackFit.expand, children: [
          Background(backgroundUrl: user.backgroundUrl),
          Row(children: [
            Container(
                padding: EdgeInsets.all(8),
                child:
                    Avatar(avatarUrl: user.avatarUrl, isBanned: user.isBanned)),
            Username(
              username: user.username,
              usergroup: user.usergroup,
              bold: true,
              onClick: () => Get.to(ProfileScreen(id: user.id)),
            ),
          ])
        ]));
  }
}
