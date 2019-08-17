import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/widget/tab-navigator.dart';
import 'package:knocky/events.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

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
  StreamSubscription _sub;

  void initState() {
    super.initState();

    initUniLinks();
    TwitterHelper().getBearerToken();

    final QuickActions quickActions = new QuickActions();

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
          type: 'action_subscriptions',
          localizedTitle: 'Subscriptions',
          icon: 'icon_help'),
      const ShortcutItem(
          type: 'action_popular',
          localizedTitle: 'Popular threads',
          icon: 'icon_help'),
      const ShortcutItem(
          type: 'action_latest',
          localizedTitle: 'Latest threads',
          icon: 'icon_help')
    ]);

    quickActions.initialize((shortcutType) {
      if (shortcutType == 'action_subscriptions') {
        AppHiveBox.getBox().then((Box box) {
          box.get('isLoggedIn', defaultValue: false).then((loginState) {
            if (loginState) {
              ScopedModel.of<AppStateModel>(context).setCurrentTab(1);
            }
          });
        });
      }
      if (shortcutType == 'action_popular')
        ScopedModel.of<AppStateModel>(context).setCurrentTab(3);
      if (shortcutType == 'action_latest')
        ScopedModel.of<AppStateModel>(context).setCurrentTab(2);
      // More handling code...
    });
  }

  @override
  void afterFirstLayout(BuildContext bcontext) {
    ScopedModel.of<AuthenticationModel>(bcontext)
        .getLoginStateFromSharedPreference(bcontext);

    // Listen for drawer open events
    eventBus.on<ClickDrawerEvent>().listen((event) {
      _scaffoldKey.currentState.openDrawer();
    });
  }

  @override
  void dispose() {
    _dataSub.cancel();
    _sub.cancel();
    super.dispose();
  }

  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Uri initialUri = await getInitialUri();
      print(initialUri.toString());
      if (initialUri != null) handleLink(initialUri);
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }

    // Attach a listener to the stream
    _sub = getUriLinksStream().listen((Uri uri) {
      handleLink(uri);
      // Use the uri and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
  }

  void handleLink (Uri uri) {
    print(uri.toString());
    print(uri.pathSegments.length);

    // Handle thread links
    if (uri.pathSegments.length > 0) {
      if (uri.pathSegments[0] == 'thread') {
        int threadId = int.tryParse(uri.pathSegments[1]);

        if (threadId != null) {
          navigatorKeys[0].currentState.push(MaterialPageRoute(
              builder: (context) => ThreadScreen(
                threadId: int.parse(uri.pathSegments[1]),
              ),
            ),);
        }
      }
    }
    uri.pathSegments.forEach((segment) {
      print(segment);
    });
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
      !await navigatorKeys[selectedTab]
          .currentState
          .maybePop(); //ignore: unnecessary_statements
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
            if (!_isLoggedIn && index == 1) {
              return;
            }

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
              icon: Icon(Icons.view_list),
              title: Text('Forum'),
            ),
            BottomNavigationBarItem(
              icon: Opacity(
                opacity: _isLoggedIn ? 1.0 : 0.5,
                child: Stack(
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
              ),
              title: Text('Subscriptions'),
            ),
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
