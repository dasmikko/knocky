import 'package:flutter/material.dart';

class PageSelector extends StatelessWidget {
  final Function onNext;
  final int pageCount;
  final int currentPage;

  PageSelector(
      {@required this.pageCount, @required this.onNext, this.currentPage: 1});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 8),
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              width: 150,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: pageSelectorButtons(context))),
          navigatorButton(context, '>', onNext)
        ]));
  }

  List<Widget> pageSelectorButtons(context) {
    final children = <Widget>[];
    for (var i = 0; i < pageCount; i++) {
      children.add(navigatorButton(context, (i + 1).toString(), onNext));
    }
    return children;
  }

  ElevatedButton navigatorButton(context, text, onClick) {
    return ElevatedButton(
        child: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
            minimumSize: Size.fromWidth(16),
            primary: Theme.of(context).primaryColor),
        onPressed: onNext);
  }
}
