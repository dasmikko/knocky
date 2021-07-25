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

  static PageSelector pageSelector(
      ItemScrollController itemScrollController, dynamic dataController) {
    return PageSelector(
      onNext: () {
        itemScrollController.jumpTo(index: 0);
        dataController.nextPage();
      },
      onPage: (page) {
        itemScrollController.jumpTo(index: 0);
        dataController.goToPage(page);
      },
      pageCount: dataController.pageCount,
      currentPage: dataController.page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 8, 8, 0),
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              width: 150,
              margin: EdgeInsets.only(right: 4),
              child: ScrollablePositionedList.separated(
                // we're missing shrinkWrap in this widget to deal with resizing
                separatorBuilder: (BuildContext context, int i) {
                  return Container(width: 4, height: double.infinity);
                },
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

  Widget navigatorButton(context, text, onClick, {highlight = false}) {
    return Container(
        width: 32,
        child: ElevatedButton(
            child: Stack(fit: StackFit.loose, children: [
              Container(
                  height: double.infinity,
                  child: Align(
                      alignment: Alignment.center,
                      child:
                          Text(text, style: TextStyle(color: Colors.white)))),
              if (highlight) highlightCaret(context)
            ]),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: Theme.of(context).primaryColor,
            ),
            onPressed: onClick));
  }

  Widget highlightCaret(context) {
    return Container(
        height: double.infinity,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(top: 20),
                child: FaIcon(FontAwesomeIcons.caretUp,
                    size: 16, color: Theme.of(context).accentColor))));
  }
}
