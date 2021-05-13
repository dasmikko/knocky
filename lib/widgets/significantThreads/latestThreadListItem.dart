import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';
import 'package:time_formatter/time_formatter.dart';

class LatestThreadListItem extends ThreadListItem {
  final SignificantThread thread;

  LatestThreadListItem({@required this.thread}) : super(threadDetails: thread);

  @override
  Widget getSubtitle(BuildContext context) {
    return Text(formatTime(thread.createdAt.millisecondsSinceEpoch),
        style: TextStyle(color: Colors.white60));
  }
}