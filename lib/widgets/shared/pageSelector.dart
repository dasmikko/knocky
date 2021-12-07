import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/controllers/paginatedController.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PageSelector extends StatelessWidget {
  final Function onNext;
  final Function onPage;
  final int pageCount;
  final int currentPage;
  final ItemScrollController scrollController = new ItemScrollController();

  PageSelector(
      {@required this.onNext,
      @required this.onPage,
      @required this.pageCount,
      this.currentPage: 1});

  static PageSelector pageSelector(ItemScrollController itemScrollController,
      PaginatedController dataController) {
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

  void changePage(int page) {
    onPage(page);
    updateCurrentPagePosition();
  }

  void updateCurrentPagePosition() {
    scrollController.scrollTo(
      curve: Curves.easeOutCirc,
      index: currentPage - 1,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      height: 38,
      child: Row(
        children: [
          navigatorButton(context, Icon(Icons.arrow_left),
              () => changePage(currentPage - 1),
              disabled: currentPage == 1),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 4, left: 4),
              child: ScrollablePositionedList.separated(
                itemScrollController: scrollController,
                // we're missing shrinkWrap in this widget to deal with resizing
                separatorBuilder: (BuildContext context, int i) {
                  return Container(width: 4, height: double.infinity);
                },
                physics: BouncingScrollPhysics(),
                initialScrollIndex: currentPage - 1,
                scrollDirection: Axis.horizontal,

                itemCount: pageCount,
                itemBuilder: (BuildContext context, int i) {
                  return navigatorButton(context, Text((i + 1).toString()),
                      () => changePage(i + 1),
                      highlight: currentPage == i + 1);
                },
              ),
            ),
          ),
          navigatorButton(context, Icon(Icons.arrow_right),
              () => changePage(currentPage + 1),
              disabled: currentPage == pageCount),
        ],
      ),
    );
  }

  Widget navigatorButton(context, Widget content, onClick,
      {highlight = false, disabled = false}) {
    return Container(
      width: 38,
      child: ElevatedButton(
          child: Stack(
            fit: StackFit.loose,
            children: [
              Container(
                height: double.infinity,
                child: Align(alignment: Alignment.center, child: content),
              ),
              if (highlight) highlightCaret(context)
            ],
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            primary: Theme.of(context).primaryColor,
          ),
          onPressed: disabled ? null : onClick),
    );
  }

  Widget highlightCaret(context) {
    return Container(
      height: double.infinity,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(top: 26),
          child: FaIcon(FontAwesomeIcons.caretUp,
              size: 16, color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
