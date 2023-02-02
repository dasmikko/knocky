import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class ProfileThreadListItem extends ThreadListItem {
  final SignificantThread? thread;

  ProfileThreadListItem({required this.thread}) : super(threadDetails: thread);

  @override
  Widget getSubtitle(BuildContext context) {
    return Container();
  }
}
