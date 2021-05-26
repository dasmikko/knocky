import 'package:flutter/material.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:knocky/widgets/shared/threadListItem.dart';

class SubscriptionListItem extends ThreadListItem {
  final ThreadAlert threadAlert;

  SubscriptionListItem({@required this.threadAlert})
      : super(threadDetails: threadAlert);

  @override
  List getTagWidgets(BuildContext context) {
    return [
      if (threadAlert.unreadPostCount > 0)
        unreadPostsButton(context, threadAlert.unreadPostCount)
    ];
  }

  @override
  List<WidgetSpan> getDetailIcons(BuildContext context) {
    return [...lockedIcon()];
  }
}
