import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widgets/post/postListItem.dart';
import 'package:knocky/widgets/shared/paginatedListView.dart';

class ThreadScreen extends PaginatedListView {
  // TODO: actually use this
  final int linkedPostId;

  ThreadScreen({@required id, page: 1, this.linkedPostId})
      : super(id: id, page: page);

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState
    extends PaginatedListViewState<ThreadController, ThreadScreen> {
  @override
  void initState() {
    dataController = Get.put(ThreadController());
    super.initState();
  }

  @override
  Widget listItem(dynamic listItemData) {
    return PostListItem(post: listItemData as ThreadPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(dataController.title ?? 'Loading thread...')),
          actions: [],
        ),
        body: selectorAndItems());
  }
}
