import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/profileThreadController.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widgets/profile/thread.dart';
import 'package:knocky/widgets/shared/paginatedListView.dart';

class ProfileThreads extends PaginatedListView {
  ProfileThreads({@required id, page: 1}) : super(id: id, page: page);

  @override
  _ProfileThreadsState createState() => _ProfileThreadsState();
}

class _ProfileThreadsState
    extends PaginatedListViewState<ProfileThreadController, ProfileThreads> {
  @override
  void initState() {
    dataController = Get.put(ProfileThreadController());
    super.initState();
  }

  @override
  Widget listItem(dynamic listItemData) {
    return ProfileThreadListItem(thread: listItemData as SignificantThread);
  }
}
