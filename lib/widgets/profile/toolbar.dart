import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widgets/post/toolbar.dart';

class ProfilePostToolbar extends Toolbar {
  final ThreadPost post;

  ProfilePostToolbar({@required this.post}) : super(post: post);

  @override
  List<Widget> contents() {
    return [timestamp(), threadTitle()];
  }

  Widget threadTitle() {
    return Flexible(
        child: Row(children: [
      Text(" in "),
      Flexible(
          child: TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero)),
              onPressed: () => Get.to(ThreadScreen(
                  id: post.threadId, page: post.page, linkedPostId: post.id)),
              child: Text('',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis)))
    ]));
  }
}
