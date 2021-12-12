import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/controllers/forumController.dart';
import 'package:knocky/models/subforum.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/screens/thread.dart';
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
    forumController.fetchMotd();
  }

  Widget motd() {
    if (forumController.motd == null) return Container();
    if (forumController.motd.isEmpty ||
        forumController.motdIsHidden(forumController.motd.first.id))
      return Container();

    return forumController.motd.length > 0
        ? Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 18),
            color: Colors.blue[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(forumController.motd.first.message),
                ),
                SizedBox(
                  width: 18,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      String stringUrl = forumController.motd.first.buttonLink;
                      int threadId = int.parse(stringUrl.split('/').last);

                      Get.to(ThreadScreen(id: threadId));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[700],
                      side: BorderSide(color: Colors.white),
                      elevation: 0,
                    ),
                    child: Text(forumController.motd.first.buttonName),
                  ),
                ),
                Container(
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    onPressed: () {
                      forumController.hiddenMotds
                          .add(forumController.motd.first.id);
                      GetStorage storage = GetStorage();
                      storage.write('hiddenMotds', forumController.hiddenMotds);
                      forumController.fetchMotd();
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.times,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Knocky'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                forumController.fetchSubforums();
                forumController.fetchMotd();
              },
            ),
          ],
        ),
        body: Obx(
          () => KnockoutLoadingIndicator(
            show: forumController.isFetching.value,
            child: RefreshIndicator(
              onRefresh: () async {
                forumController.fetchSubforums();
                forumController.fetchMotd();
              },
              child: Stack(
                children: [
                  motd(),
                  Container(
                    padding: forumController.motd.length > 0 &&
                            !forumController
                                .motdIsHidden(forumController.motd.first.id)
                        ? EdgeInsets.only(top: 100)
                        : null,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
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
                          onTapItemFooter: (int threadId, int page) {
                            Get.to(
                              () => ThreadScreen(id: threadId, page: page),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: MainDrawer());
  }
}
