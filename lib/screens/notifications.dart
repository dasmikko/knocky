import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/notificationController.dart';

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
      body: Container(
        child: ListView.builder(itemBuilder: (BuildContext context, int index) {
          return Container();
        }),
      ),
    );
  }
}
