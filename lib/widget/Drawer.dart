import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class DrawerWidget extends StatefulWidget {
  Function onLoginOpen;
  Function onLoginCloses;
  Function closeLoginWebview;
  Function onLoginFinished;

  DrawerWidget(
      {this.onLoginOpen,
      this.onLoginCloses,
      this.closeLoginWebview,
      this.onLoginFinished});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _loginState = false;
  int _userId = 0;
  String _username = '';
  String _avatar = '';
  String _background = '';
  int _usergroup = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _loginState = prefs.getBool('isLoggedIn') != null
            ? prefs.getBool('isLoggedIn')
            : false;

        _userId = prefs.getInt('userId');
        _username = prefs.getString('username');
        _avatar = prefs.getString('avatar_url');
        _background = prefs.getString(
                       'background_url');
        _usergroup = prefs.getInt('usergroup');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: _loginState ? BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.4), BlendMode.dstATop),
                  image: CachedNetworkImageProvider(
                      'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                          _background)),
            ) : null,
            child: Text(_loginState ? _username : 'Not logged in'),
          ),
          if (!_loginState)
            ListTile(
              title: Text('Login'),
              onTap: () {
                final flutterWebviewPlugin = new FlutterWebviewPlugin();

                flutterWebviewPlugin.onBack.listen((onData) async {
                  if (onData == null) {
                    flutterWebviewPlugin.close();
                    this.widget.onLoginCloses();
                  }
                });

                flutterWebviewPlugin.onUrlChanged.listen((String url) async {
                  if (url.contains(KnockoutAPI.baseurl + "auth/finish")) {
                    Uri parsedUrl = Uri.parse(url);
                    String userJson =
                        Uri.decodeFull(parsedUrl.queryParameters['user']);

                    Map valueMap = json.decode(userJson);

                    print(valueMap);

                    setState(() {
                      _userId = valueMap['id'];
                      _username = valueMap['username'];
                      _avatar = valueMap['avatar_url'];
                      _background = valueMap['background_url'];
                      _usergroup = valueMap['usergroup'];
                    });

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    await prefs.setInt('userId', valueMap['id']);
                    await prefs.setString('username', valueMap['username']);
                    await prefs.setString('avatar_url', valueMap['avatar_url']);
                    await prefs.setString(
                        'background_url', valueMap['background_url']);
                    await prefs.setInt('usergroup', valueMap['id']);

                    flutterWebviewPlugin.reloadUrl(KnockoutAPI.baseurlSite);
                  }

                  if (url == KnockoutAPI.baseurlSite) {
                    var cookies =
                        await CookieManager.getCookies(KnockoutAPI.baseurl);

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    String cookieString = '';
                    String jwt = null;

                    // Get needed JWTToken
                    cookies.forEach((element) {
                      if (element['name'] == 'knockoutJwt') {
                        cookieString +=
                            element['name'] + "=" + element['value'] + "; ";

                        jwt = element['value'];
                      }
                    });

                    await prefs.setBool('isLoggedIn', true);
                    await prefs.setString('cookieString', cookieString);

                    setState(() {
                      _loginState = true;
                    });

                    //flutterWebviewPlugin.evalJavascript('document.cookie = "user=localStorage.getItem("currentUser")";');

                    flutterWebviewPlugin.close();
                    this.widget.onLoginFinished();
                  }
                });

                this.widget.onLoginOpen();

                flutterWebviewPlugin.launch(
                  KnockoutAPI.baseurlSite + "login",
                  withLocalStorage: true,
                  appCacheEnabled: true,
                  withJavascript: true,
                  userAgent:
                      "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
                );
              },
            ),
          ListTile(
            title: Text('Subsriptions'),
          ),
          if (_loginState)
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                await prefs.setBool('isLoggedIn', false);
                await prefs.setString('cookieString', null);

                setState(() {
                  _loginState = false;
                });
              },
            )
        ],
      ),
    );
  }
}
