import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/hiddenThreadsController.dart';
import 'package:knocky/controllers/subscriptionController.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/forum/ForumListItem.dart';
import 'package:knocky/widgets/hiddenThreads/hiddenThreadListItem.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';
import 'package:knocky/widgets/subforum/subforumListItem.dart';
import 'package:knocky/widgets/subscriptions/subscriptionListItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ManageHiddenThreadsScreen extends StatefulWidget {
  @override
  _ManageHiddenThreadsScreenState createState() =>
      _ManageHiddenThreadsScreenState();
}

class _ManageHiddenThreadsScreenState extends State<ManageHiddenThreadsScreen> {
  final HiddenThreadsController hiddenThreadsController =
      Get.put(HiddenThreadsController());

  @override
  void initState() {
    super.initState();
    hiddenThreadsController.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hidden threads'),
      ),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: hiddenThreadsController.isFetching.value,
            child: RefreshIndicator(
              onRefresh: () async => hiddenThreadsController.fetch(),
              child: hiddenThreadsController.threads.value.length == 0
                  ? noHiddenThreads()
                  : threads(),
            ),
          ),
        ),
      ),
    );
  }

  Widget noHiddenThreads() {
    return Center(
      child: Text(
        "You don't have hidden any threads...",
        style: TextStyle(
          fontSize: 22,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget threads() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ScrollablePositionedList.builder(
        // ignore: invalid_use_of_protected_member
        itemCount: hiddenThreadsController.threads.value.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return HiddenThreadListItem(
            threadDetails: hiddenThreadsController.threads.value[index],
          );
        },
      ),
    );
  }
}
