import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/widget/tab-navigator.dart';

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
  final navigatorKey = GlobalKey<NavigatorState>();

  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  void initState() {
    super.initState();

    _loginIsOpen = false;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    getSubforums();
    ScopedModel.of<AuthenticationModel>(context)
        .getLoginStateFromSharedPreference(context);
  }

  @override
  void dispose() {
    super.dispose();
    _dataSub.cancel();
  }

  Future<void> getSubforums() {
    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();
    _dataSub = KnockoutAPI().getSubforums().asStream().listen((subforums) {
      setState(() {
        _subforums = subforums;
        _isFetching = false;
      });
    });

    return _dataSub.asFuture();
  }

  Future<bool> _onWillPop() async {
    int selectedTab = ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).currentTab;
    if (navigatorKeys[selectedTab].currentState.canPop()) {
      !await navigatorKeys[selectedTab].currentState.maybePop();
      return false;
    }
    return true;

    /*if (_loginIsOpen) {
      return false;
    } else {
      return true;
    }*/
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

  Widget _buildOffstageNavigator(int tabItem) {
    int selectedTab = ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).currentTab;
    return Offstage(
      offstage: selectedTab != tabItem,
      child: TabNavigator(
        tabItem: tabItem,
        navigatorKeys: navigatorKeys,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int selectedTab = ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).currentTab;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(0),
          _buildOffstageNavigator(1),
          _buildOffstageNavigator(2),
          _buildOffstageNavigator(3),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: (int index) {
            if (index != selectedTab) {
              setState(() {
                ScopedModel.of<AppStateModel>(context).setCurrentTab(index);
              });

              if (selectedTab != 0 && navigatorKeys[selectedTab].currentState.canPop()) {
                navigatorKeys[selectedTab]
                    .currentState
                    .pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
              }
            } else {
              if (navigatorKeys[selectedTab].currentState.canPop()) {
                navigatorKeys[selectedTab]
                    .currentState
                    .pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
              }
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list), title: Text('Forum')),
            BottomNavigationBarItem(
                icon: Stack(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.solidNewspaper),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          color: Colors.red,
                          child: Text('1'),
                        ),
                      ),
                    )
                  ],
                ),
                title: Text('Subscriptions')),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.solidClock), title: Text('Latest')),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.fire), title: Text('Popular'))
          ],
        ),
      ),
    );
  }
}
