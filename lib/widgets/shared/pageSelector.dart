import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageSelector extends StatelessWidget {
  final Function onNext;
  final Function onPage;
  final int pageCount;
  final int currentPage;

  PageSelector(
      {@required this.onNext,
      @required this.onPage,
      @required this.pageCount,
      this.currentPage: 1});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 8, 8, 0),
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              width: 150, // todo: shrink width depending on amount of pages
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: pageCount,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int i) {
                  return navigatorButton(
                      context, (i + 1).toString(), () => onPage(i + 1),
                      highlight: currentPage == i + 1);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 2,
                  );
                },
              )),
          if (currentPage != pageCount) navigatorButton(context, '>', onNext)
        ]));
  }

  ElevatedButton navigatorButton(context, text, onClick, {highlight = false}) {
    return ElevatedButton(
        child: Stack(children: [
          Container(
              height: double.infinity,
              child: Align(
                  alignment: Alignment.center,
                  child: Text(text, style: TextStyle(color: Colors.white)))),
          if (highlight) highlightCaret(context)
        ]),
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromWidth(4),
          primary: Theme.of(context).primaryColor,
        ),
        onPressed: onClick);
  }

  Widget highlightCaret(context) {
    return Container(
        color: Colors.blue,
        height: double.infinity,
        width: 0,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(top: 20),
                child: FaIcon(FontAwesomeIcons.caretUp,
                    size: 16, color: Theme.of(context).accentColor))));
  }
}
