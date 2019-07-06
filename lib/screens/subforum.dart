import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widget/SubforumDetailListItem.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SubforumScreen extends StatefulWidget {
  final Subforum subforumModel;

  SubforumScreen({this.subforumModel});

  @override
  _SubforumScreenState createState() => _SubforumScreenState();
}

class _SubforumScreenState extends State<SubforumScreen> with AfterLayoutMixin<SubforumScreen> {
  SubforumDetails details;


  @override
  void afterFirstLayout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var api = new KnockoutAPI();
    // Calling the same function "after layout" to resolve the issue.
    api.getSubforumDetails(widget.subforumModel.id).then((res) {
      setState(() {
        details = res;

        if (!prefs.getBool('showNSFWThreads')) {
          details.threads = details.threads.where((item) => !item.title.contains('NSFW')).toList();
        }        
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subforumModel.name)),
      body: details == null ? Text('Node graph out of date') : ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: details.threads.length,
          itemBuilder: (BuildContext context, int index) {
            var item = details.threads[index];
            return SubforumDetailListItem(threadDetails: item);
          },
        ),
    );
  }
}
