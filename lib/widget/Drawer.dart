import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:knocky/screens/events.dart';
import 'package:knocky/screens/latestThreads.dart';
import 'package:knocky/screens/popularThreads.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intent/intent.dart' as Intent;
import 'package:intent/action.dart' as Action;
import 'package:knocky/screens/subscriptions.dart';
import 'package:knocky/screens/settings.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/subscriptions.dart';

class DrawerWidget extends StatefulWidget {
  final Function onLoginOpen;
  final Function onLoginCloses;
  final Function closeLoginWebview;
  final Function onLoginFinished;

  DrawerWidget(
      {this.onLoginOpen,
      this.onLoginCloses,
      this.closeLoginWebview,
      this.onLoginFinished});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
    ScopedModel.of<AuthenticationModel>(context)
        .getLoginStateFromSharedPreference(context);
  }

  void onClickLogin(BuildContext context) async {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    String loginUrl = 'login';
    String fullUrl = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullUrl = prefs.getString('env') == 'knockout'
        ? KnockoutAPI.KNOCKOUT_SITE_URL + loginUrl
        : KnockoutAPI.QA_SITE_URL + loginUrl;

    flutterWebviewPlugin.onBack.listen((onData) async {
      if (onData == null) {
        flutterWebviewPlugin.close();
        this.widget.onLoginCloses();
      }
    });

    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.contains(prefs.getString('env') == 'knockout'
          ? KnockoutAPI.KNOCKOUT_URL + "auth/finish"
          : KnockoutAPI.QA_URL + "auth/finish")) {
        print(url);
        Uri parsedUrl = Uri.parse(url);
        String userJson = Uri.decodeFull(parsedUrl.queryParameters['user']);

        print(userJson);

        Map valueMap = json.decode(userJson);

        print(valueMap);

        await ScopedModel.of<AuthenticationModel>(context).setLoginState(
            true,
            valueMap['id'],
            valueMap['username'] != null
                ? valueMap['username']
                : 'User has no username?',
            valueMap['avatar_url'],
            valueMap['background_url'],
            valueMap['usergroup']);

        flutterWebviewPlugin.reloadUrl(KnockoutAPI.baseurlSite);
      }

      if (url == KnockoutAPI.baseurlSite) {
        String cookieUrl = prefs.getString('env') == 'knockout'
            ? KnockoutAPI.KNOCKOUT_URL
            : KnockoutAPI.QA_URL;

        var cookies = await CookieManager.getCookies(cookieUrl);
        String cookieString = '';

        // Get needed JWTToken
        cookies.forEach((element) {
          if (element['name'] == 'knockoutJwt') {
            cookieString += element['name'] + "=" + element['value'] + "; ";
          }
        });

        ScopedModel.of<AuthenticationModel>(context)
            .setCookieString(cookieString);

        //flutterWebviewPlugin.evalJavascript('document.cookie = "user=localStorage.getItem("currentUser")";');

        flutterWebviewPlugin.close();
        this.widget.onLoginFinished();
      }
    });

    this.widget.onLoginOpen();

    flutterWebviewPlugin.launch(
      fullUrl,
      withLocalStorage: true,
      appCacheEnabled: true,
      withJavascript: true,
      userAgent:
          //"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36",
    );
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
          if (!_loginState)
            ListTile(
              leading: Icon(FontAwesomeIcons.signInAlt),
              title: Text('Login'),
              onTap: () {
                onClickLogin(context);
              },
            ),
          ListTile(
            enabled: _loginState,
            leading: Icon(FontAwesomeIcons.bullhorn),
            title: Text('Events'),
            onTap: onTapEvents,
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.discord),
            title: Text('Discord'),
            onTap: () {
              Intent.Intent()
                ..setAction(Action.Action.ACTION_VIEW)
                ..setData(Uri.parse('https://discord.gg/ce8pVKH'))
                ..startActivity().catchError((e) => print(e));
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.cog),
            title: Text('Settings'),
            onTap: onTapSettings,
          ),
          if (_loginState)
            ListTile(
              leading: Icon(FontAwesomeIcons.lockOpen),
              title: Text('Logout'),
              onTap: () async {
                ScopedModel.of<AuthenticationModel>(context).logout();
                ScopedModel.of<SubscriptionModel>(context).clearList();
              },
            )
        ],
      ),
    );
  }
}
