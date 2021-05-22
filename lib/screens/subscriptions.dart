import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/subscriptionController.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
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
    subscriptionController.fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
      ),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: subscriptionController.isFetching.value,
            child: RefreshIndicator(
                onRefresh: () async => subscriptionController.fetch(),
                child: events()),
          ),
        ),
      ),
    );
  }

  Widget events() {
    return Container(
        padding: EdgeInsets.all(4),
        child: ScrollablePositionedList.builder(
            // ignore: invalid_use_of_protected_member
            itemCount: subscriptionController.subscriptions.value?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              var threadAlert =
                  subscriptionController.subscriptions.elementAt(index);
              return SubscriptionListItem(threadAlert: threadAlert);
            }));
  }
}
