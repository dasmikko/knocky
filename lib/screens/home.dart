import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/screens/settings.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:knocky/widget/CategoryListItem.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
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
    getSubforums();
    ScopedModel.of<AuthenticationModel>(context).getLoginStateFromSharedPreference();
  }

  @override
  void dispose () {
    super.dispose();
    _dataSub.cancel();
  }

  Future<void> getSubforums() {
    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();
    _dataSub = KnockoutAPI().getSubforums().asStream().listen((subforums){
      setState(() {
        _subforums = subforums;
        _isFetching = false;
      });
    });

    return _dataSub.asFuture();
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
        drawer: DrawerWidget(
          onLoginOpen: () {
            setState(() {
              _loginIsOpen = true;
            });
          },
          onLoginCloses: () {
            setState(() {
              _loginIsOpen = false;
            });
          },
          onLoginFinished: () {
            setState(() {
              _loginIsOpen = false;
            });
          },
        ),
        body: Container(
          child: RefreshIndicator(
            onRefresh: getSubforums,
            child: !_isFetching
                ? ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: _subforums.length,
                    itemBuilder: (BuildContext context, int index) {
                      Subforum item = _subforums[index];
                      return CategoryListItem(
                        subforum: item,
                        onTapItem: onTapItem,
                      );
                    },
                  )
                : KnockoutLoadingIndicator(),
          ),
        ),
      ),
    );
  }
}
