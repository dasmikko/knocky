import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../KnockoutLoadingIndicator.dart';

class PaginatedListView extends StatefulWidget {
  final int id;
  final int page;

  PaginatedListView({@required this.id, this.page = 1});

  @override
  PaginatedListViewState createState() => PaginatedListViewState();
}

class PaginatedListViewState<C extends PaginatedController,
    W extends PaginatedListView> extends State<W> {
  C dataController;
  final itemScrollController = new ItemScrollController();

  @override
  void initState() {
    super.initState();
    dataController.initState(widget.id, widget.page);
  }

  @protected
  Widget selectorAndItems() {
    return Container(
      child: Obx(
        () => KnockoutLoadingIndicator(
          show: dataController.isFetching.value,
          child: RefreshIndicator(
              onRefresh: () async => dataController.fetch(),
              child: Stack(children: [
                PageSelector.pageSelector(itemScrollController, dataController),
                listItems()
              ])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return selectorAndItems();
  }

  Widget listItems() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 48, 0, 0),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          minCacheExtent: MediaQuery.of(context).size.height,
          itemCount: dataController.dataInPageCount ?? 0,
          itemBuilder: (BuildContext context, int index) {
            var dataAtIndex = dataController.dataAtIndex(index);
            return listItem(dataAtIndex);
          },
        ));
  }

  @protected
  Widget listItem(dynamic listItemData) {
    return Container();
  }
}
