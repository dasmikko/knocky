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
  Box box;
  InAppWebView webView;
  InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();

    // Setup the webview
    this.webView = InAppWebView(
      onWebViewCreated: (controller) {
       this.webViewController = controller; 
      },
      shouldOverrideUrlLoading: onUrlChange,
      initialUrl: this.widget.loginUrl,
      initialOptions: InAppWebViewWidgetOptions(
        androidInAppWebViewOptions: AndroidInAppWebViewOptions(
          allowContentAccess: true,
          allowUniversalAccessFromFileURLs: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          mixedContentMode:
              AndroidInAppWebViewMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        ),
        inAppWebViewOptions: InAppWebViewOptions(
            userAgent:
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36",
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    this.box = await AppHiveBox.getBox();
  }

  void onUrlChange(InAppWebViewController controller, String url) async {
    controller.loadUrl(url: url);
    
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

      Navigator.pop(context, true);
    }
  }

  Future<bool> _onWillPop() async {
    if (await this.webViewController.canGoBack()) {
      this.webViewController.goBack();
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
        body: this.webView,
      ),
    );
  }
}
