import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/notificationController.dart';
import 'package:knocky/models/notification.dart';
import 'package:knocky/widgets/notifications/notificationPostReplyListItem.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationController notificationController =
      Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    notificationController.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Obx(() => Container(
          child: notificationController.notifications != null
              ? ListView.builder(
                  itemCount: notificationController.notifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    print(notificationController.notifications.length);
                    NotificationModel notification =
                        notificationController.notifications.elementAt(index);

                    if (notification.type == 'POST_REPLY')
                      return NotificationPostReplyListItem(notification);
                    return Container(
                        child: Text('Message notification' + index.toString()));
                  })
              : Container())),
    );
  }
}
