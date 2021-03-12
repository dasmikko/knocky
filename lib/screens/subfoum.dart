import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/subforumController.dart';
import 'package:knocky/models/subforum.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';

class SubforumScreen extends StatefulWidget {
  final Subforum subforum;

  SubforumScreen({@required this.subforum});

  @override
  _SubforumScreenState createState() => _SubforumScreenState();
}

class _SubforumScreenState extends State<SubforumScreen> {
  final SubforumController subforumController = Get.put(SubforumController());

  @override
  void initState() {
    subforumController.fetchSubforum(this.widget.subforum.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.subforum.name),
      ),
      body: Container(
        child: Obx(
          () => KnockoutLoadingIndicator(
            show: subforumController.isFetching.value,
            child: this.subforumController.subforum.value.id != null
                ? RefreshIndicator(
                    onRefresh: () async => subforumController
                        .fetchSubforum(this.widget.subforum.id),
                    child: ListView.builder(
                      itemCount:
                          subforumController.subforum.value.threads.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(subforumController
                            .subforum.value.threads[index].title);
                      },
                    ),
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
