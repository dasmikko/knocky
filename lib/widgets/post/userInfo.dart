import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/screens/profile.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:knocky/widgets/shared/background.dart';
import 'package:knocky/widgets/shared/username.dart';

class UserInfo extends StatelessWidget {
  final ThreadUser? user;
  final bool? isNewPost;

  UserInfo({required this.user, this.isNewPost});

  Border? postHeaderBorder() {
    AuthController authController = Get.put(AuthController());
    final int ownUserId = authController.userId.value;

    if (ownUserId == user!.id) {
      return Border(
        left: BorderSide(color: Color.fromRGBO(255, 216, 23, 1), width: 2),
      );
    }

    if (this.isNewPost!) {
      return Border(
        left: BorderSide(color: Color.fromRGBO(67, 104, 173, 1), width: 2),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: postHeaderBorder(),
      ),
      height: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Background(backgroundUrl: user!.backgroundUrl),
          Row(children: [
            Container(
                padding: EdgeInsets.all(8),
                child:
                    Avatar(avatarUrl: user!.avatarUrl, isBanned: user!.isBanned)),
            Username(
              username: user!.username,
              title: user!.title,
              pronouns: user!.pronouns,
              role: user!.role,
              bold: true,
              onClick: () => Get.to(ProfileScreen(id: user!.id)),
            ),
          ])
        ],
      ),
    );
  }
}
