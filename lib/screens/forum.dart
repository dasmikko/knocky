import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/screens/thread.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:knocky/widget/CategoryListItem.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:uni_links/uni_links.dart';

class ForumScreen extends StatefulWidget {
  final ScaffoldState scaffoldKey;
  final Function onMenuClick;

  ForumScreen({this.scaffoldKey, this.onMenuClick});

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with AfterLayoutMixin<ForumScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Subforum> _subforums = new List<Subforum>();
  bool _loginIsOpen;
  bool _isFetching = false;
  StreamSubscription<List<Subforum>> _dataSub;
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

    ScopedModel.of<AppStateModel>(context).updateSyncData();

    _loginIsOpen = false;
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

  void handleLink(Uri uri) {
    print(uri.toString());
    print(uri.pathSegments.length);

    // Handle thread links
    if (uri.pathSegments.length > 0) {
      if (uri.pathSegments[0] == 'thread') {
        int threadId = int.tryParse(uri.pathSegments[1]);

        if (threadId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                threadId: int.parse(uri.pathSegments[1]),
              ),
            ),
          );
        }
      }
    }
    uri.pathSegments.forEach((segment) {
      print(segment);
    });
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
    _sub.cancel();
    super.dispose();
  }

  Future<void> getSubforums(context) {
    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();
    Future _future = KnockoutAPI().getSubforums();

    _future.catchError((error) {
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
    ScopedModel.of<AppStateModel>(context).updateSyncData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubforumScreen(
          subforumModel: item,
        ),
      ),
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

    final List<SyncDataMentionModel> mentions =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).mentions;

    final int totalUnreadPosts =
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true).totalUnreadPosts;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Icon(Icons.menu),
                  if (totalUnreadPosts != null &&
                      totalUnreadPosts >
                          0) // Show a little indicator that you have mentions
                    Positioned(
                      top: -5,
                      right: -5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          color: Colors.red,
                          child: Text(
                            totalUnreadPosts.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    )
                ],
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              }),
          title: Text('Knocky'),
        ),
        drawerEdgeDragWidth: 30.0,
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
        body: KnockoutLoadingIndicator(
          show: _isFetching,
          child: Container(
            child: RefreshIndicator(
              onRefresh: () => getSubforums(context),
              child: ListView.builder(
                padding: EdgeInsets.all(0.0),
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
