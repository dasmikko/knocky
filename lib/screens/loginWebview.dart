import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/settingsController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/controllers/authController.dart';
import 'dart:io' show Platform;

class LoginWebviewScreen extends StatefulWidget {
  final String loginUrl;

  LoginWebviewScreen({this.loginUrl});

  @override
  _LoginWebviewState createState() => _LoginWebviewState();
}

class _LoginWebviewState extends State<LoginWebviewScreen>
    with AfterLayoutMixin<LoginWebviewScreen> {
  MyInAppBrowser browser;

  @override
  void initState() {
    super.initState();

    this.browser = new MyInAppBrowser(
        context: this.context,
        onBrowserExit: (bool loginStatus) {
          Get.back(result: loginStatus, closeOverlays: true);
        });

    this.browser.openUrlRequest(
          urlRequest: new URLRequest(url: Uri.parse(this.widget.loginUrl)),
          options: InAppBrowserClassOptions(
            inAppWebViewGroupOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                javaScriptEnabled: true,
                userAgent:
                    "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36",
              ),
              ios: IOSInAppWebViewOptions(
                isPagingEnabled: true,
              ),
              android: AndroidInAppWebViewOptions(
                allowContentAccess: true,
                allowFileAccess: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                disabledActionModeMenuItems:
                    AndroidActionModeMenuItem.MENU_ITEM_SHARE,
                mixedContentMode:
                    AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
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
  final AuthController authController = Get.put(AuthController());
  final SettingsController settingsController = Get.put(SettingsController());
  bool loginWasSuccessfull = false;

  MyInAppBrowser({this.context, this.onBrowserExit});

  @override
  Future onBrowserCreated() async {
    //print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(Uri url) async {
    //print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(Uri url) async {
    //print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(Uri url, int code, String message) {
    //print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {}

  @override
  void onExit() {
    this.onBrowserExit(this.loginWasSuccessfull);
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      NavigationAction navigationAction) async {
    var urlRequest = navigationAction.request;
    var url = urlRequest.url;

    //print("\n\n override $url\n\n");

    if (Platform.isAndroid) {
      this.webViewController.loadUrl(urlRequest: urlRequest);
    }

    //SharedPreferences prefs = await SharedPreferences.getInstance();

    if (url.toString().contains(settingsController.apiEnv.value == 'knockout'
        ? KnockoutAPI.KNOCKOUT_URL + "auth/finish"
        : KnockoutAPI.QA_URL + "auth/finish")) {
      String userJson = Uri.decodeFull(url.queryParameters['user']);

      Map valueMap = json.decode(userJson);

      // Get the JWT token from the cookie inside the webview
      String cookieUrl = settingsController.apiEnv.value == 'knockout'
          ? KnockoutAPI.KNOCKOUT_URL
          : KnockoutAPI.QA_URL;

      var cookieManager = CookieManager.instance();
      var cookies = await cookieManager.getCookies(url: Uri.parse(cookieUrl));
      String cookieString = '';

      // Get needed JWTToken
      cookies.forEach((element) {
        if (element.name == 'knockoutJwt') {
          cookieString += element.name + "=" + element.value + "; ";
        }
      });

      authController.login(
          valueMap['id'],
          valueMap['username'] != null
              ? valueMap['username']
              : 'User has no username?',
          valueMap['avatar_url'],
          valueMap['background_url'],
          valueMap['usergroup'],
          cookieString);

      this.loginWasSuccessfull = true;

      await this.close();
    }

    return NavigationActionPolicy.ALLOW;
  }
}
