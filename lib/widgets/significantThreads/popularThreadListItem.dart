import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/forumController.dart';
import 'package:knocky/models/v2/thread.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class PopularThreadListItem extends ThreadListItem {
  final SubforumThread thread;
  final ForumController forumController = Get.put(ForumController());

  PopularThreadListItem({@required this.thread}) : super(threadDetails: thread);

  @override
  Widget getSubtitle(BuildContext context) {
    return Text(
        "${thread.viewers.memberCount} viewing now, in ${forumController.subforums.where((subforum) => subforum.id == thread.subforumId).first.name}",
        style: TextStyle(color: Colors.white60));
  }
}
