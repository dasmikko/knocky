import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:knocky/models/events.dart';
import 'package:knocky/screens/thread.dart';

class EventListItem extends StatelessWidget {
  final KnockoutEvent event;

  EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    var content = jsonDecode(event.content!)["content"] as List;
    var onTap = getOnTap(context, content);
    var texts = (content).map((item) => contentTextSpan(item)).toList();
    return Card(
        child: Container(
            padding: EdgeInsets.all(8),
            child: InkWell(
              onTap: onTap as void Function()?,
              child:
                  Wrap(children: [RichText(text: TextSpan(children: texts))]),
            )));
  }

  // Either goes to a thread, or does nothing
  Function getOnTap(BuildContext context, List content) {
    // content is either a String or a Map
    Map<String, dynamic>? contentMap = content.firstWhere(
        (item) => item is Map && item["link"] != null,
        orElse: () => null);

    if (contentMap == null) {
      return () => {};
    }

    // in case something goes wrong, just return an empty function
    try {
      var threadId = int.parse(contentMap["link"].replaceAll('/thread/', ''));
      return () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => ThreadScreen(id: threadId)));
    } catch (exception) {
      return () => {};
    }
  }

  TextSpan contentTextSpan(dynamic item) {
    if (item is String) {
      return TextSpan(text: item);
    } else {
      return TextSpan(text: item["text"], style: TextStyle(color: Colors.blue));
    }
  }
}
