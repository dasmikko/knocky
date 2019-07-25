import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/widget/CategoryListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';

class ForumScreen extends StatefulWidget {
  final ScaffoldState scaffoldKey;

  ForumScreen({this.scaffoldKey});

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with AfterLayoutMixin<ForumScreen> {
  List<Subforum> _subforums = new List<Subforum>();
  bool _loginIsOpen;
  bool _isFetching = false;
  StreamSubscription<List<Subforum>> _dataSub;

  void initState() {
    super.initState();

    _loginIsOpen = false;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    getSubforums(context);
    ScopedModel.of<AuthenticationModel>(context)
        .getLoginStateFromSharedPreference(context);
  }

  @override
  void dispose() {
    _dataSub.cancel();
    super.dispose();
  }

  Future<void> getSubforums(context) {
    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();
    print('Gettings subforums');

    Future _future = KnockoutAPI().getSubforums();

    _future.catchError((error) {
      print('error:');
      print(error.toString());
      setState(() {
        _isFetching = false;
      });

      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to get categories. Try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));

      _dataSub?.cancel();
    });

    _dataSub = _future.asStream().listen((subforums) {
      setState(() {
        _subforums = subforums;
        _isFetching = false;
      });
    });

    return _future;
  }

  Future<bool> _onWillPop() async {
    if (_loginIsOpen) {
      return false;
    } else {
      return true;
    }
  }

  bool notNull(Object o) => o != null;

  void onTapItem(Subforum item) {
    print('Clicked item ' + item.id.toString());

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SubforumScreen(
                subforumModel: item,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Knocky'),
        ),
        body: KnockoutLoadingIndicator(
          show: _isFetching,
          child: Container(
            child: RefreshIndicator(
              onRefresh: () => getSubforums(context),
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: _subforums.length,
                itemBuilder: (BuildContext context, int index) {
                  Subforum item = _subforums[index];
                  return CategoryListItem(
                    subforum: item,
                    onTapItem: onTapItem,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
