import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/bansController.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/widgets/profile/bans.dart';
import 'package:knocky/widgets/profile/posts.dart';
import 'package:knocky/widgets/profile/threads.dart';

class ProfileBody extends StatefulWidget {
  final UserProfile profile;

  ProfileBody({@required this.profile});

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final BansController bansController = Get.put(BansController());

  @override
  void initState() {
    super.initState();
    bansController.initState(widget.profile.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Expanded(
            child: new DefaultTabController(
          length: hasBans() ? 3 : 2,
          child: Scaffold(
            body: TabBarView(children: [...tabContents()]),
            appBar: new AppBar(
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
        )));
  }

  bool hasBans() {
    return !bansController.isFetching.value &&
        bansController.bans.value.userBans != null &&
        bansController.bans.value.userBans.length > 0;
  }

  List<dynamic> tabContents() {
    List<dynamic> tabContents = [
      ProfilePosts(id: widget.profile.id),
      ProfileThreads(id: widget.profile.id)
    ];
    if (hasBans()) {
      tabContents.add(ProfileBans(bans: bansController.bans.value));
    }
    return tabContents;
  }

  List<Tab> tabs() {
    var tabs = [
      tab('Posts', widget.profile.posts.toString()),
      tab('Threads', widget.profile.threads.toString()),
    ];
    if (hasBans()) {
      tabs.add(
          tab('Bans', bansController.bans.value.userBans.length.toString()));
    }
    return tabs;
  }

  Tab tab(String title, String subtitle) {
    return new Tab(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title),
      Text("($subtitle)", style: TextStyle(color: Colors.grey, fontSize: 12))
    ]));
  }
}
