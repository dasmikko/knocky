import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/widget/tab-navigator.dart';
import 'package:knocky/events.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  StreamSubscription<List<Subforum>> _dataSub;
  final navigatorKey = GlobalKey<NavigatorState>();
  bool _loginIsOpen = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext bcontext) {
    ScopedModel.of<AuthenticationModel>(bcontext)
        .getLoginStateFromSharedPreference(bcontext);

    // Listen for drawer open events
    eventBus
      .on<ClickDrawerEvent>()
      .listen((event) {
        _scaffoldKey.currentState.openDrawer();
      });
  }

  @override
  void dispose() {
    _dataSub.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // handle login overlay
    if (_loginIsOpen) {
      return false;
    }

    int selectedTab =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true)
            .currentTab;
    if (navigatorKeys[selectedTab].currentState.canPop()) {
      !await navigatorKeys[selectedTab].currentState.maybePop(); //ignore: unnecessary_statements
      return false;
    }
    return true;
  }

  Widget _buildOffstageNavigator(int tabItem) {
    int selectedTab =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true)
            .currentTab;
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
    int selectedTab =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true)
            .currentTab;
    int unreadPosts =
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true)
            .totalUnreadPosts;

    bool _isLoggedIn =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .isLoggedIn;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
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
          selectedItemColor: Colors.red,
          currentIndex: selectedTab,
          onTap: (int index) {
            if (index != selectedTab) {
              setState(() {
                ScopedModel.of<AppStateModel>(context).setCurrentTab(index);
              });

              if (selectedTab != 0 &&
                  navigatorKeys[selectedTab].currentState.canPop()) {
                navigatorKeys[selectedTab].currentState.pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
              }
            } else {
              if (navigatorKeys[selectedTab].currentState.canPop()) {
                navigatorKeys[selectedTab].currentState.pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
              }
            }
          },
          items: [
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.view_list),
                icon: Icon(Icons.view_list), title: Text('Forum'),),
            if (_isLoggedIn)
              BottomNavigationBarItem(
                  icon: Stack(
                    children: <Widget>[
                      Container(
                          width: 70,
                          child: Icon(FontAwesomeIcons.solidNewspaper)),
                      if (unreadPosts > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              color: Colors.red,
                              child: Text(
                                unreadPosts.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
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
