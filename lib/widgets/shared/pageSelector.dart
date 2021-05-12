import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
              width: 150, // TODO: shrink width depending on amount of pages
              // TODO: add equal padding between each button, even if buttons
              // have different widths (single vs double digits)
              child: ScrollablePositionedList.builder(
                physics: BouncingScrollPhysics(),
                initialScrollIndex: currentPage - 1,
                scrollDirection: Axis.horizontal,
                itemCount: pageCount,
                itemBuilder: (BuildContext context, int i) {
                  return navigatorButton(
                      context, (i + 1).toString(), () => onPage(i + 1),
                      highlight: currentPage == i + 1);
                },
              )),
          if (currentPage != pageCount) navigatorButton(context, '>', onNext)
        ]));
  }

  ElevatedButton navigatorButton(context, text, onClick, {highlight = false}) {
    return ElevatedButton(
        child: Stack(fit: StackFit.loose, children: [
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

  // TODO: the width of the text in the navigator can expand to two digits
  // which causes the highlight caret to be off-center, i.e. how do we make
  // sure this caret is always in the middle of the stack?
  Widget highlightCaret(context) {
    return IntrinsicWidth(
        child: Container(
            height: double.infinity,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: FaIcon(FontAwesomeIcons.caretUp,
                        size: 16, color: Theme.of(context).accentColor)))));
  }
}
