import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/drawer/mainDrawer.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ThreadScreen extends StatefulWidget {
  final int id;
  final int page;
  final int linkedPostId;

  ThreadScreen({@required this.id, this.page: 1, this.linkedPostId});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final ThreadController threadController = Get.put(ThreadController());

  @override
  void initState() {
    stderr.writeln(this.widget.id);
    threadController.fetchThreadPage(this.widget.id, page: this.widget.page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    stderr.writeln(threadController.thread?.value);
    return Scaffold(
        appBar: AppBar(
          title: Text('Knocky'),
          actions: [],
        ),
        body: Container(
          child: Obx(
            () => KnockoutLoadingIndicator(
              show: threadController.isFetching.value,
              child: RefreshIndicator(
                  onRefresh: () async =>
                      threadController.fetchThreadPage(this.widget.page),
                  child: ScrollablePositionedList.builder(
                    itemCount: threadController.thread.value != null
                        ? threadController.thread.value.posts.length
                        : 0,
                    itemBuilder: (BuildContext context, int index) {
                      ThreadPost post =
                          threadController.thread.value.posts[index];
                      return PostListItem(
                        post: post,
                      );
                    },
                  )),
            ),
          ),
        ),
        drawer: MainDrawer());
  }
}
