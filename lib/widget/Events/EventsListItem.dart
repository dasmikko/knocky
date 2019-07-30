import 'dart:convert';

import 'package:flutter/material.dart';

class EventsListItem extends StatelessWidget {
  final String content;

  EventsListItem({this.content});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> event = jsonDecode(this.content);
    List items = event['content'];
    print(event['content']);

    print(items);

    List<TextSpan> widgets = List();

    items.forEach((item) {
      print(item.runtimeType);
      if (item is String) {
        widgets.add(TextSpan(text: item));
      }

      if (item is Map) {
        widgets.add(TextSpan(text: item['text']));
      }
    });

    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Wrap(children: [
          RichText(text: TextSpan(children: widgets),)
        ]),
      ),
    );
  }
}
