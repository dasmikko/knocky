import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/significantThreadsController.dart';
import 'package:knocky/models/significantThreads.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/drawer/mainDrawer.dart';
import 'package:knocky/widgets/significantThreads/significantThreadListItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SignificantThreadsScreen extends StatefulWidget {
  final SignificantThreads threadsToShow;

  SignificantThreadsScreen({this.threadsToShow: SignificantThreads.Popular});

  @override
  _SignificantThreadsScreenState createState() =>
      _SignificantThreadsScreenState();
}

class _SignificantThreadsScreenState extends State<SignificantThreadsScreen> {
  final controller = Get.put(SignificantThreadsController());

  @override
  void initState() {
    super.initState();
    controller.initState(widget.threadsToShow);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        appBar: AppBar(
          title: Text(controller.threadsToFetchName),
          actions: [
            IconButton(
                icon: FaIcon(
                    controller.threadsToFetch == SignificantThreads.Latest
                        ? FontAwesomeIcons.fire
                        : FontAwesomeIcons.clock),
                onPressed: () => controller.toggleType())
          ],
        ),
        body: Container(
          child: KnockoutLoadingIndicator(
            show: controller.isFetching.value,
            child: RefreshIndicator(
                onRefresh: () async => controller.fetch(),
                child: Stack(children: [threads()])),
          ),
        ),
        drawer: MainDrawer()));
  }

  Widget threads() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ScrollablePositionedList.builder(
          //  TODO: how do we see if the list is null or not without accessing .value?
          itemCount: controller.threads.value?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            var thread = controller.threads.elementAt(index);
            return SignificantThreadListItem(thread: thread);
          },
        ));
  }
}
