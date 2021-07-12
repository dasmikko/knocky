import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/profileController.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/usergroup.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:knocky/widgets/shared/background.dart';
import 'package:knocky/widgets/shared/username.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  final int id;

  ProfileScreen({@required this.id});
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    profileController.initState(widget.id);
    super.initState();
  }

  // todo: avatar size should be 115
  // todo: avatar and username container should be in middle of lower part of bg
  // todo: bg should be less tall?
  Widget header(BuildContext context) {
    return Container(
        height: 256,
        child: Stack(fit: StackFit.expand, children: [
          Background(
              backgroundUrl: profileController.profile.value.backgroundUrl),
          Container(
              margin: EdgeInsets.fromLTRB(8, 64, 8, 0),
              child: Row(children: [
                Avatar(
                    avatarUrl: profileController.profile.value?.avatarUrl,
                    isBanned: profileController.profile.value?.banned),
                Container(
                    margin: EdgeInsets.only(left: 8),
                    child: Username(
                        username: profileController.profile.value?.username,
                        usergroup: profileController.profile.value?.usergroup,
                        bold: true))
              ]))
        ]));
  }

  Widget overview(BuildContext context) {
    //var usergroup = profileController.profile.value.usergroup;
    //var usergroupLabel = UsergroupHelper.userGroupToString(usergroup);
    //print(usergroupLabel);
    return ListView(children: [
      Container(
        height: 512,
        color: Colors.red,
      )
    ]);
  }

  Widget ratings(BuildContext context) {
    // todo: add ratings
  }

  Widget contentTabs(BuildContext context) {
    // todo: add latest-posts-threads-bans tabs
    // todo: add latests tab
    // todo: add posts list
    // todo: add threads list
    // todo: add bans list
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => KnockoutLoadingIndicator(
        show: profileController.isFetching.value,
        child: !profileController.isFetching.value
            ? ListView(children: [header(context), overview(context)])
            : Container()));
  }
}
