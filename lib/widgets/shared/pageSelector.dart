import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PageSelector extends StatefulWidget {
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
  _PageSelectorState createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  ItemScrollController scrollController = new ItemScrollController();

  void changePage(int page) {
    widget.onPage(page);
  }

  void updateCurrentPagePosition() {
    var alignment = _getAlignmentValue();
    scrollController.jumpTo(
        index: widget.currentPage - 1, alignment: alignment);
  }

  // this just exists to make sure we don't go over bounds on either sides
  double _getAlignmentValue() {
    var alignment = 0.5;
    var index = widget.currentPage - 1;
    var middleIndexCount = 4;
    var selectorWidth = (0.5 / middleIndexCount);
    if (index < middleIndexCount) {
      alignment = selectorWidth * index;
    } else if (index > widget.pageCount - middleIndexCount) {
      alignment = 1 +
          (index - ((widget.pageCount) - 1)) * selectorWidth -
          selectorWidth;
    }
    return alignment;
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => updateCurrentPagePosition());
    var selector = Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      height: 32,
      child: Row(
        children: [
          navigatorButton(context, Icon(Icons.arrow_left),
              () => changePage(widget.currentPage - 1),
              disabled: widget.currentPage == 1),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 4, left: 4),
              child: ScrollablePositionedList.separated(
                itemScrollController: scrollController,
                // we're missing shrinkWrap in this widget to deal with resizing
                separatorBuilder: (BuildContext context, int i) {
                  return Container(width: 4, height: double.infinity);
                },
                physics: ClampingScrollPhysics(),
                initialScrollIndex: widget.currentPage - 1,
                scrollDirection: Axis.horizontal,

                itemCount: widget.pageCount,
                itemBuilder: (BuildContext context, int i) {
                  return navigatorButton(context, Text((i + 1).toString()),
                      () => changePage(i + 1),
                      highlight: widget.currentPage == i + 1);
                },
              ),
            ),
          ),
          navigatorButton(context, Icon(Icons.arrow_right),
              () => changePage(widget.currentPage + 1),
              disabled: widget.currentPage == widget.pageCount),
        ],
      ),
    );
    return selector;
  }

  Widget navigatorButton(context, Widget content, onClick,
      {highlight = false, disabled = false}) {
    return Container(
      width: 32,
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
          margin: EdgeInsets.only(top: 20),
          child: FaIcon(FontAwesomeIcons.caretUp,
              size: 16, color: Theme.of(context).accentColor),
        ),
      ),
    );
  }
}
