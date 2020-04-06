import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/screens/events.dart';
import 'package:knocky/screens/forum.dart';
import 'package:knocky/screens/latestThreads.dart';
import 'package:knocky/screens/login.dart';
import 'package:knocky/screens/popularThreads.dart';
import 'package:knocky/screens/thread.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intent/intent.dart' as Intent;
import 'package:intent/action.dart' as Action;
import 'package:knocky/screens/subscriptions.dart';
import 'package:knocky/screens/settings.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/appState.dart';
import 'package:knocky/state/subscriptions.dart';

class DrawerWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  DrawerWidget({
    this.scaffoldKey,
  });

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> with AfterLayoutMixin {
  double _iconSize = 18.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    ScopedModel.of<AuthenticationModel>(context)
        .getLoginStateFromSharedPreference(context);

    ScopedModel.of<AppStateModel>(context).updateSyncData();
    ScopedModel.of<SubscriptionModel>(context).getSubscriptions();
  }

  void onClickLogin(BuildContext context) async {
    //final flutterWebviewPlugin = new FlutterWebviewPlugin();
    String loginUrl = 'login';
    String fullUrl = '';

    Box box = await AppHiveBox.getBox();

    fullUrl = await box.get('env') == 'knockout'
        ? KnockoutAPI.KNOCKOUT_SITE_URL + loginUrl
        : KnockoutAPI.QA_SITE_URL + loginUrl;

    Navigator.pop(context);
    bool wasLoggedIn = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          loginUrl: fullUrl,
        ),
      ),
    );

    print('was logged in state ' + wasLoggedIn.toString());

    if (wasLoggedIn) {
      this.widget.scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                'Login was successful!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
    }

    return;
  }

  void onTapForum() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ForumScreen(),
        ),
        ModalRoute.withName('/'));
  }

  void onTapSubsriptions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(),
      ),
    );
  }

  void onTapLatestThreads() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LatestThreadsScreen(),
      ),
    );
  }

  void onTapPopulaThreads() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PopularThreadsScreen(),
      ),
    );
  }

  void onTapSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          appContext: context,
        ),
      ),
    );
  }

  void onTapEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventsScreen(),
      ),
    );
  }

  void onTapOnMention(SyncDataMentionModel mention) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadScreen(
          page: mention.threadPage,
          threadId: mention.threadId,
          postCount: mention.threadPage * 20,
        ),
      ),
    );
    ScopedModel.of<AppStateModel>(context).updateSyncData();
  }

  @override
  Widget build(BuildContext context) {
    final bool _loginState =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .isLoggedIn;
    final String _background =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .background;
    final String _username =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .username;
    final String _avatar =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .avatar;

    final bool isBanned =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .isBanned;

    final String banMessage =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .banMessage;

    final List<SyncDataMentionModel> mentions =
        ScopedModel.of<AppStateModel>(context, rebuildOnChange: true).mentions;

    final int unreadPosts =
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true)
            .totalUnreadPosts;

    final bool isFetchingSubscriptions =
        ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true)
            .isFetching;

    /*final int banThreadId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .banThreadId;*/

    final Decoration drawerHeaderDecoration = _loginState && _background != ''
        ? BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.center,
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.4), BlendMode.dstATop),
              image: CachedNetworkImageProvider(
                  'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                      _background),
            ),
          )
        : null;

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            //ignore: missing_required_param
            accountName: Text(_loginState ? _username : 'Not logged in'),
            currentAccountPicture: _loginState
                ? CachedNetworkImage(
                    imageUrl:
                        'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                            _avatar,
                  )
                : null,
            decoration: drawerHeaderDecoration,
          ),
          if (isBanned)
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('You are banned!'),
                  Text('Reason: ' + banMessage)
                ],
              ),
            ),
          ListTile(
            enabled: _loginState,
            leading: Icon(
              Icons.view_list,
              size: _iconSize,
            ),
            title: Text('Forum'),
            onTap: onTapForum,
          ),
          ListTile(
            enabled: _loginState,
            leading: Icon(
              FontAwesomeIcons.solidNewspaper,
              size: _iconSize,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isFetchingSubscriptions)
                  Container(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )),
                if (unreadPosts > 0)
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        color: Colors.red,
                        child: Text(
                          unreadPosts.toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text('Subscriptions'),
            onTap: onTapSubsriptions,
          ),
          ListTile(
            enabled: _loginState,
            leading: Icon(
              FontAwesomeIcons.solidClock,
              size: _iconSize,
            ),
            title: Text('Latest threads'),
            onTap: onTapLatestThreads,
          ),
          ListTile(
            enabled: _loginState,
            leading: Icon(
              FontAwesomeIcons.fire,
              size: _iconSize,
            ),
            title: Text('Popular threads'),
            onTap: onTapPopulaThreads,
          ),
          Divider(
            color: Colors.grey,
          ),
          if (!_loginState)
            ListTile(
              leading: Icon(
                FontAwesomeIcons.signInAlt,
                size: _iconSize,
              ),
              title: Text('Login'),
              onTap: () {
                onClickLogin(context);
              },
            ),
          ListTile(
            enabled: _loginState,
            leading: Icon(
              FontAwesomeIcons.bullhorn,
              size: _iconSize,
            ),
            title: Text('Events'),
            onTap: onTapEvents,
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.discord,
              size: _iconSize,
            ),
            title: Text('Discord'),
            onTap: () {
              Intent.Intent()
                ..setAction(Action.Action.ACTION_VIEW)
                ..setData(Uri.parse('https://discord.gg/ce8pVKH'))
                ..startActivity().catchError((e) => print(e));
            },
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.cog,
              size: _iconSize,
            ),
            title: Text('Settings'),
            onTap: onTapSettings,
          ),
          if (_loginState)
            ListTile(
              leading: Icon(
                FontAwesomeIcons.lockOpen,
                size: _iconSize,
              ),
              title: Text('Logout'),
              onTap: () async {
                ScopedModel.of<AuthenticationModel>(context).logout();
                ScopedModel.of<SubscriptionModel>(context).clearList();
              },
            ),
          Divider(
            color: Colors.grey,
          ),
          if (_loginState)
            ListTile(
              title: Text('Mentions'),
              trailing: mentions != null && mentions.length > 0
                  ? Chip(
                      backgroundColor: Colors.red,
                      label: Text(mentions.length.toString()),
                    )
                  : null,
            ),
          if (_loginState)
            for (var item in mentions)
              ListTile(
                title: Text(item.content),
                onTap: () => onTapOnMention(item),
              ),
          if (_loginState && mentions != null && mentions.length == 0)
            ListTile(
              title: Text(
                'You have no new mentions',
                style: TextStyle(color: Colors.grey),
              ),
              dense: true,
            )
        ],
      ),
    );
  }
}
