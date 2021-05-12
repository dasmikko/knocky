import 'package:flutter/material.dart';

class PageSelector extends StatelessWidget {
  final Function onNext;
  final Function onPage;
  final int pageCount;
  final int currentPage;

  PageSelector(
      {@required this.pageCount,
      @required this.onNext,
      @required this.onPage,
      this.currentPage: 1});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 8, 8, 0),
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
      var pageNumber = i + 1;
      children.add(navigatorButton(
          context, pageNumber.toString(), () => onPage(pageNumber),
          highlight: pageNumber == currentPage));
    }
    return children;
  }

  ElevatedButton navigatorButton(context, text, onClick, {highlight = false}) {
    return ElevatedButton(
        child: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
            minimumSize: Size.fromWidth(16),
            primary: Theme.of(context).primaryColor,
            shape: highlight
                ? RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).accentColor, width: 2),
                  )
                : RoundedRectangleBorder()),
        onPressed: onClick);
  }
}
