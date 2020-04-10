import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';

class LoginScreen extends StatefulWidget {
  final String loginUrl;

  LoginScreen({this.loginUrl});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<LoginScreen>
    with AfterLayoutMixin<LoginScreen> {
  MyInAppBrowser browser;

  @override
  void initState() {
    super.initState();

    this.browser = new MyInAppBrowser(
        context: this.context,
        onBrowserExit: () async {
          bool isLoggedIn = await ScopedModel.of<AuthenticationModel>(context).isLoggedIn;
          Navigator.of(context).pop(isLoggedIn);
        });

    this.browser.open(
          url: this.widget.loginUrl,
          options: InAppBrowserClassOptions(
            inAppWebViewWidgetOptions: InAppWebViewWidgetOptions(
              androidInAppWebViewOptions: AndroidInAppWebViewOptions(
                allowContentAccess: true,
                allowUniversalAccessFromFileURLs: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                disabledActionModeMenuItems: AndroidInAppWebViewModeMenuItem.MENU_ITEM_SHARE,
                mixedContentMode: AndroidInAppWebViewMixedContentMode
                    .MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              inAppWebViewOptions: InAppWebViewOptions(
                userAgent:
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36",
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
              ),
            ),
          ),
        );
  }

  @override
  void afterFirstLayout(BuildContext context) async {}

  Future<bool> _onWillPop() async {
    if (await this.browser.webViewController.canGoBack()) {
      this.browser.webViewController.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class MyInAppBrowser extends InAppBrowser {
  BuildContext context;
  Function onBrowserExit;

  MyInAppBrowser({this.context, this.onBrowserExit});

  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
    this.onBrowserExit();
  }

  @override
  void shouldOverrideUrlLoading(String url) async {
    print("\n\n override $url\n\n");
    this.webViewController.loadUrl(url: url);

    Box box = await AppHiveBox.getBox();

    if (url.contains(await box.get('env') == 'knockout'
        ? KnockoutAPI.KNOCKOUT_URL + "auth/finish"
        : KnockoutAPI.QA_URL + "auth/finish")) {
      Uri parsedUrl = Uri.parse(url);
      String userJson = Uri.decodeFull(parsedUrl.queryParameters['user']);

      Map valueMap = json.decode(userJson);

      await ScopedModel.of<AuthenticationModel>(context).setLoginState(
          true,
          valueMap['id'],
          valueMap['username'] != null
              ? valueMap['username']
              : 'User has no username?',
          valueMap['avatar_url'],
          valueMap['background_url'],
          valueMap['usergroup']);

      // Get the JWT token from the cookie inside the webview
      String cookieUrl = await box.get('env') == 'knockout'
          ? KnockoutAPI.KNOCKOUT_URL
          : KnockoutAPI.QA_URL;

      var cookieManager = new CookieManager();
      var cookies = await cookieManager.getCookies(url: cookieUrl);
      String cookieString = '';

      // Get needed JWTToken
      cookies.forEach((element) {
        if (element.name == 'knockoutJwt') {
          cookieString += element.name + "=" + element.value + "; ";
        }
      });

      print(cookieString);

      ScopedModel.of<AuthenticationModel>(context)
          .setCookieString(cookieString);

      this.close();
    }

    @override
    void onLoadResource(LoadedResource response) {}

    @override
    void onConsoleMessage(ConsoleMessage consoleMessage) {}
  }
}
