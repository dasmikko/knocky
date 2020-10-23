import 'dart:async';
import 'package:flutter/material.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:knocky_edge/helpers/twitterApi.dart';
import 'package:knocky_edge/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/models/syncData.dart';
import 'package:knocky_edge/screens/subforum.dart';
import 'package:knocky_edge/state/appState.dart';
import 'package:knocky_edge/state/subscriptions.dart';
import 'package:knocky_edge/widget/CategoryListItem.dart';
import 'package:knocky_edge/widget/Drawer.dart';
import 'package:knocky_edge/widget/KnockoutLoadingIndicator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky_edge/state/authentication.dart';

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

    print('initState');

    TwitterHelper().getBearerToken();

    ScopedModel.of<AppStateModel>(context).updateSyncData();

    _loginIsOpen = false;
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    getSubforums(context);
    await ScopedModel.of<AuthenticationModel>(context)
        .getLoginStateFromSharedPreference(context);

    if (ScopedModel.of<AuthenticationModel>(context).isLoggedIn) {
      ScopedModel.of<SubscriptionModel>(context).getSubscriptions();
    }
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
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true)
            .totalUnreadPosts;

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
          scaffoldKey: _scaffoldKey,
        ),
        body: KnockoutLoadingIndicator(
          show: _isFetching,
          child: Container(
            child: RefreshIndicator(
              onRefresh: () => getSubforums(this.context),
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
