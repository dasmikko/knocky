import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/eventController.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/events/eventListItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final EventController eventController = Get.put(EventController());

  @override
  void initState() {
    eventController.fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Knockout Events'),
      ),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: eventController.isFetching.value,
            child: RefreshIndicator(
                onRefresh: () async => eventController.fetch(),
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
            itemCount: eventController.events.value?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              var event = eventController.events.elementAt(index);
              return EventListItem(event: event);
            }));
  }
}
