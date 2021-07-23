import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knocky/controllers/bansController.dart';
import 'package:knocky/controllers/profileController.dart';
import 'package:knocky/helpers/icons.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfileRatings.dart';
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
  final BansController bansController = Get.put(BansController());
  UserProfile get profile => profileController.profile.value;
  UserProfileRatings get ratings => profileController.ratings.value;

  @override
  void initState() {
    super.initState();
    profileController.initState(widget.id);
    bansController.initState(widget.id);
  }

  Widget headerLabels(BuildContext context) {
    return Expanded(
        child: Container(
            //color: Colors.green,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Username(
                  username: profile?.username,
                  usergroup: profile?.usergroup,
                  bold: true,
                  banned: profile?.banned,
                  fontSize: 26),
              UsergroupLabel(
                  usergroup: profile?.usergroup,
                  banned: profile?.banned,
                  joinDate: profile?.joinDate),
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
          Background(backgroundUrl: profile?.backgroundUrl),
          gradientOverlay(),
          Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              // color: Colors.yellow,
              child: Stack(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Avatar(
                      avatarUrl: profile?.avatarUrl, isBanned: profile?.banned),
                  headerLabels(context)
                ]),
                userRatings(context)
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

  Widget userRatings(BuildContext context) {
    ratings.ratings.sort((a, b) => b.count.compareTo(a.count));
    return Container(
        height: double.infinity,
        margin: EdgeInsets.only(bottom: 8),
        alignment: Alignment.bottomCenter,
        child: Container(
            // color: Colors.green,
            height: 24,
            child: ListView(
                scrollDirection: Axis.horizontal,
                children: [for (var i in ratings.ratings) rating(i)])));
  }

  Tab tab(String title, String subtitle) {
    return new Tab(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title),
      Text("($subtitle)", style: TextStyle(color: Colors.grey, fontSize: 12))
    ]));
  }

  bool hasBans() {
    return !bansController.isFetching.value &&
        bansController.bans.value.userBans != null &&
        bansController.bans.value.userBans.length > 0;
  }

  List<Tab> tabs() {
    var tabs = [
      tab('Posts', profile.posts.toString()),
      tab('Threads', profile.threads.toString()),
    ];
    print(bansController);
    if (hasBans()) {
      tabs.add(
          tab('Bans', bansController.bans.value.userBans.length.toString()));
    }
    return tabs;
  }

  Widget body(BuildContext context) {
    return Obx(() => Container(
          color: Colors.red,
          height: 48,
          child: new DefaultTabController(
            length: hasBans() ? 3 : 2,
            child: new AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new TabBar(
                    tabs: [...tabs()],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        appBar: AppBar(
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
                    ? Column(children: [header(context), body(context)])
                    : Container()))));
  }
}
