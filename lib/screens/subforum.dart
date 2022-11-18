import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/subforumController.dart';
import 'package:knocky/models/forum.dart' as Forum;
import 'package:knocky/models/subforumv2.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/shared/pageSelector.dart';
import 'package:knocky/widgets/subforum/subforumListItem.dart';

class SubforumScreen extends StatefulWidget {
  final Forum.Subforum subforum;

  SubforumScreen({@required this.subforum});

  @override
  _SubforumScreenState createState() => _SubforumScreenState();
}

class _SubforumScreenState extends State<SubforumScreen> {
  final SubforumController subforumController = Get.put(SubforumController());

  @override
  void initState() {
    super.initState();
    subforumController.initState(widget.subforum.id, 1);
  }

  Widget pageSelector() {
    return PageSelector(
      onNext: () {
        //itemScrollController.jumpTo(index: 0);
        subforumController.nextPage();
      },
      onPage: (page) {
        //itemScrollController.jumpTo(index: 0);
        subforumController.goToPage(page);
      },
      pageCount: subforumController.pageCount,
      currentPage: subforumController.page,
    );
  }

  List<Widget> generateWidgetList() {
    List<Widget> widgets = [];

    // Add paginator
    widgets.add(
      Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: pageSelector(),
      ),
    );

    if (subforumController.data.value.threads != null) {
      subforumController.data.value.threads.forEach((thread) {
        widgets.add(
          SubforumListItem(
            threadDetails: thread,
          ),
        );
      });
    }

    widgets.add(
      Container(
        margin: EdgeInsets.only(bottom: 8),
        child: pageSelector(),
      ),
    );

    return widgets;
  }

  Widget threads() {
    List<Widget> widgets = generateWidgetList();

    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int index) {
        return widgets[index];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.subforum.name),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 0.0),
          child: Obx(
            () => AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: subforumController.isFetching.value ? 1 : 0,
              child: LinearProgressIndicator(),
            ),
          ),
        ),
      ),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: subforumController.data.value == null &&
                subforumController.isFetching.value,
            child: RefreshIndicator(
              onRefresh: () async => subforumController.fetchData(),
              child: subforumController.data.value != null
                  ? threads()
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }
}
