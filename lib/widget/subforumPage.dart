import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/widget/SubforumDetailListItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';

class SubforumPage extends StatefulWidget {
  final Subforum subforumModel;
  final int page;
  final bool isSwiping;
  SubforumPage({this.subforumModel, this.page, this.isSwiping});

  @override
  _SubforumPagenState createState() => _SubforumPagenState();
}

class _SubforumPagenState extends State<SubforumPage>
    with AfterLayoutMixin<SubforumPage> {
  SubforumDetails details;
  StreamSubscription<SubforumDetails> _dataSub;
  bool _isFetching = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    loadPage();
  }

  @override
  void dispose() {
    super.dispose();
    _dataSub.cancel();
  }

  Future<void> loadPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();
    _dataSub = KnockoutAPI()
        .getSubforumDetails(widget.subforumModel.id, page: widget.page)
        .asStream()
        .listen((onData) {
      setState(() {
        _isFetching = false;
        if (onData != null) {
          details = onData;

          if (prefs.getBool('showNSFWThreads') == null ||
              !prefs.getBool('showNSFWThreads')) {
            details.threads = details.threads
                .where((item) => !item.title.contains('NSFW'))
                .toList();
          }
        }
      });
    });

    return _dataSub.asFuture();
  }

  Widget content() {
    if (details == null) return Container();
    return RefreshIndicator(
      onRefresh: loadPage,
      child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: details.threads.length,
              itemBuilder: (BuildContext context, int index) {
                var item = details.threads[index];
                return SubforumDetailListItem(threadDetails: item);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KnockoutLoadingIndicator(show: _isFetching, child: content(), blurBackground: false,);
  }
}
