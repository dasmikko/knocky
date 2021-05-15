import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class PopularThreadListItem extends ThreadListItem {
  final SignificantThread thread;

  PopularThreadListItem({@required this.thread}) : super(threadDetails: thread);

  @override
  Widget getSubtitle(BuildContext context) {
    // TODO: add ... in ${thread.subforumId}
    // How do we convert subforumId to subforum name?
    return Text("${thread.viewers.memberCount} viewing now",
        style: TextStyle(color: Colors.white60));
  }
}
