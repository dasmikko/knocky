import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/drawer/mainDrawer.dart';

class ThreadScreen extends StatefulWidget {
  final int id;
  final int page;

  ThreadScreen({@required this.id, this.page: 1});

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
                  child: Container()),
            ),
          ),
        ),
        drawer: MainDrawer());
  }
}
