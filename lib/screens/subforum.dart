import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widget/SubforumDetailListItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/widget/subforumPage.dart';

class SubforumScreen extends StatefulWidget {
  final Subforum subforumModel;

  SubforumScreen({this.subforumModel});

  @override
  _SubforumScreenState createState() => _SubforumScreenState();
}

class _SubforumScreenState extends State<SubforumScreen>
    with AfterLayoutMixin<SubforumScreen> {
  SubforumDetails details;
  bool isSwiping = false;
  int _totalPages;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    _totalPages = (widget.subforumModel.totalThreads / 40).ceil();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    setState(() {
      
    });
  }

  Widget content() {
    return PageView.builder(
        itemCount: _totalPages,
        onPageChanged: (int page) {
          setState(() {
           _currentPage = page + 1; 
          });
        },
        controller: PageController(initialPage: 0),
        itemBuilder: (BuildContext context, int position) {
          return SubforumPage(
            subforumModel: widget.subforumModel,
            page: position + 1,
            isSwiping: isSwiping,
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subforumModel.name)),
      body: content(),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 56,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Page: ' +
                    _currentPage.toString() +
                    ' / ' +
                    _totalPages.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
