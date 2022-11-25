import 'package:flutter/material.dart';
import 'package:knocky/helpers/format.dart';
import 'package:knocky/models/v2/thread.dart';

import 'package:knocky/widgets/shared/threadListItem.dart';

class LatestThreadListItem extends ThreadListItem {
  final SubforumThread thread;

  LatestThreadListItem({@required this.thread}) : super(threadDetails: thread);

  @override
  Widget getSubtitle(BuildContext context) {
    return Text(Format.humanReadableTimeSince(thread.createdAt),
        style: TextStyle(color: Colors.white60));
  }
}
