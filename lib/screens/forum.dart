import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/controllers/forumController.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/drawer/mainDrawer.dart';
import 'package:knocky/widgets/forum/ForumListItem.dart';
import 'package:knocky/models/forum.dart';
import 'package:knocky/models/subforumv2.dart' as Subforumv2;
import 'package:layout/layout.dart';

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
    //forumController.fetchMotd();
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
                      FontAwesomeIcons.xmark,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  // TODO: Remimplement MOTD

  Widget mobileView(BuildContext context) {
    return ListView.builder(
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
    );
  }

  Widget tabletView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        children: [
          Wrap(
            children: List.generate(
              forumController.subforums.length,
              (index) {
                Subforum subforum = forumController.subforums[index];
                return FractionallySizedBox(
                  widthFactor: 0.5,
                  child: ForumListItem(
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
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
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
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 0.0),
            child: Obx(
              () => AnimatedOpacity(
                duration: Duration(milliseconds: 250),
                opacity: forumController.isFetching.value ? 1 : 0,
                child: LinearProgressIndicator(),
              ),
            ),
          ),
        ),
        body: Obx(
          () => RefreshIndicator(
            onRefresh: () async {
              forumController.fetchSubforums();
              forumController.fetchMotd();
            },
            child: KnockoutLoadingIndicator(
              show: forumController.subforums.length == 0 &&
                  forumController.isFetching.value,
              child: context.breakpoint > LayoutBreakpoint.sm
                  ? tabletView(context)
                  : mobileView(context),
            ),
          ),
        ),
        drawer: MainDrawer());
  }
}
