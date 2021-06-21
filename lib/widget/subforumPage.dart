import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:knocky_edge/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/models/subforumDetails.dart';
import 'package:knocky_edge/widget/SubforumDetailListItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky_edge/widget/KnockoutLoadingIndicator.dart';

class SubforumPage extends StatefulWidget {
  final Subforum subforumModel;
  final int page;
  final bool isSwiping;
  final Function isScrollingDown;
  final Function isScrollingUp;
  final Function onInit;
  final bool bottomBarVisible;
  final Function onError;

  SubforumPage(
      {this.subforumModel,
      this.page,
      this.isSwiping,
      this.isScrollingDown,
      this.isScrollingUp,
      this.onInit,
      this.bottomBarVisible,
      this.onError});

  @override
  _SubforumPagenState createState() => _SubforumPagenState();
}

class _SubforumPagenState extends State<SubforumPage>
    with AfterLayoutMixin<SubforumPage> {
  SubforumDetails details;
  StreamSubscription<SubforumDetails> _dataSub;
  bool _isFetching = false;
  ScrollController scrollController = ScrollController();

  @override
  void afterFirstLayout(BuildContext context) async {
    this.widget.onInit(loadPage);
    loadPage();

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (this.widget.bottomBarVisible) {
          this.widget.isScrollingDown();
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!this.widget.bottomBarVisible) {
          this.widget.isScrollingUp();
        }
      }

      if (scrollController.position.atEdge) {
        this.widget.isScrollingUp();
      }
    });
  }

  @override
  void dispose() {
    _dataSub.cancel();
    super.dispose();
  }

  Future<void> loadPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();

    Future _future = KnockoutAPI()
        .getSubforumDetails(widget.subforumModel.id, page: widget.page)
        .catchError((error) {
      throw (error);
      print(error);
      this.widget.onError();
      setState(() {
        _isFetching = false;
      });
    });

    _dataSub = _future.asStream().listen((onData) {
      setState(() {
        _isFetching = false;
        if (onData != null) {
          details = onData;

          if (prefs.getBool('showNSFWThreads') == null ||
              !prefs.getBool('showNSFWThreads')) {
            details.threads = details.threads.where((item) {
              if (item.tags == null) return true;
              bool isNSFWThread = false;

              item.tags.forEach((tag) {
                if (tag.values.contains('NSFW')) {
                  print(tag.values);
                  print('Is nsfw thread');
                  isNSFWThread = true;
                }
              });

              return !isNSFWThread;
            }).toList();
          }
        }
      });
    });

    return _future;
  }

  Widget content() {
    return RefreshIndicator(
      onRefresh: loadPage,
      child: details == null
          ? Container()
          : ListView.builder(
              controller: scrollController,
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
    return KnockoutLoadingIndicator(
      show: _isFetching,
      child: content(),
      blurBackground: false,
    );
  }
}
