import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/subscriptionController.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:knocky/widgets/subscriptions/subscriptionListItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SubscriptionsScreen extends StatefulWidget {
  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  @override
  void initState() {
    super.initState();
    subscriptionController.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Subscriptions'),
        ),
        body: Container(
            child: Obx(() => KnockoutLoadingIndicator(
                  show: subscriptionController.isFetching.value,
                  child: RefreshIndicator(
                    onRefresh: () async => subscriptionController.fetch(),
                    child: Stack(children: [pageSelector(), subscriptions()]),
                  ),
                ))));
  }

  Widget pageSelector() {
    return PageSelector(
      onNext: () => subscriptionController.nextPage(),
      onPage: (page) => subscriptionController.goToPage(page),
      pageCount: subscriptionController.pageCount,
      currentPage: subscriptionController.page,
    );
  }

  Widget subscriptions() {
    return Container(
        padding: EdgeInsets.fromLTRB(4, 48, 4, 4),
        child: ScrollablePositionedList.builder(
            // ignore: invalid_use_of_protected_member
            itemCount:
                subscriptionController.subscriptions.value.alerts.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              var threadAlert = subscriptionController
                  .subscriptions.value.alerts
                  .elementAt(index);
              return SubscriptionListItem(threadAlert: threadAlert);
            }));
  }
}
