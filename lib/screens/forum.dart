import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/forumController.dart';
import 'package:knocky/models/subforum.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/drawer/mainDrawer.dart';
import 'package:knocky/widgets/forum/ForumListItem.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with AfterLayoutMixin<ForumScreen> {
  final ForumController forumController = Get.put(ForumController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    forumController.fetchSubforums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Knocky'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: forumController.fetchSubforums,
            ),
          ],
        ),
        body: Obx(
          () => KnockoutLoadingIndicator(
            show: forumController.isFetching.value,
            child: RefreshIndicator(
              onRefresh: () async => forumController.fetchSubforums(),
              child: ListView.builder(
                itemCount: forumController.subforums.length,
                itemBuilder: (BuildContext context, int index) {
                  Subforum subforum = forumController.subforums[index];
                  return ForumListItem(
                    subforum: subforum,
                    onTapItem: (Subforum subforumItem) {
                      Get.to(
                        () => SubforumScreen(subforum: subforum),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        drawer: MainDrawer());
  }
}
