import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knocky/controllers/profileController.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/models/usergroup.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/post/ratingsChooser.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:knocky/widgets/shared/background.dart';
import 'package:knocky/widgets/shared/usergroup.dart';
import 'package:knocky/widgets/shared/username.dart';

class ProfileScreen extends StatefulWidget {
  final int id;

  ProfileScreen({@required this.id});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final DateFormat joinFormat = new DateFormat('MMMM yyyy');

  @override
  void initState() {
    super.initState();
    profileController.initState(widget.id);
  }

  Widget headerLabels(BuildContext context) {
    return Expanded(
        child: Container(
            //color: Colors.green,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Username(
                  username: profileController.profile.value?.username,
                  usergroup: profileController.profile.value?.usergroup,
                  bold: true,
                  fontSize: 26),
              UsergroupLabel(
                usergroup: profileController.profile.value?.usergroup,
                extraText:
                    "joined ${joinFormat.format(profileController.profile.value?.joinDate)}",
              ),
              Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Text(profileController.details.value?.bio,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color.fromRGBO(255, 255, 255, 0.6))))
            ])));
  }

  Widget gradientOverlay() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Container(
            height: 64,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.75)],
            ))));
  }

  Widget header(BuildContext context) {
    return Container(
        height: 208,
        child: Stack(fit: StackFit.expand, children: [
          Background(
              backgroundUrl: profileController.profile.value?.backgroundUrl),
          gradientOverlay(),
          Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              // color: Colors.yellow,
              child: Stack(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Avatar(
                      avatarUrl: profileController.profile.value?.avatarUrl,
                      isBanned: profileController.profile.value?.banned),
                  headerLabels(context)
                ]),
                ratings(context)
              ]))
        ]));
  }

  Widget rating(UserProfileRating rating) {
    var ratingItem = ratingIconMap[rating.name];
    if (ratingItem == null) {
      print(rating.name);
      return Container();
    }
    return Row(children: [
      RatingsChooser.ratingIcon(ratingItem),
      Container(
          child: Text(rating.count.toString(), style: TextStyle(fontSize: 12)),
          margin: EdgeInsets.fromLTRB(4, 0, 8, 0))
    ]);
  }

  Widget ratings(BuildContext context) {
    profileController.ratings.value.ratings
        .sort((a, b) => b.count.compareTo(a.count));
    return Container(
        height: double.infinity,
        margin: EdgeInsets.only(bottom: 8),
        alignment: Alignment.bottomCenter,
        child: Container(
            // color: Colors.green,
            height: 24,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (var i in profileController.ratings.value.ratings) rating(i)
            ])));
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
    return Obx(() => Scaffold(
        appBar: AppBar(
          title: Text('NoRegaaaard'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: profileController.fetch,
            ),
          ],
        ),
        body: Container(
            child: KnockoutLoadingIndicator(
                show: profileController.isFetching.value,
                child: !profileController.isFetching.value
                    ? ListView(children: [header(context)])
                    : Container()))));
  }
}
