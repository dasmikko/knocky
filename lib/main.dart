import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'screens/subforum.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Knockout'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  List<Subforum> _subforums = new List<Subforum>();
  bool _loginIsOpen;

  void initState() {
    super.initState();

    _loginIsOpen = false;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    getSubforums().then((subforums) {
      setState(() {
        _subforums = subforums;
      });
    });

    authCheck();
  }

  Future<bool> _onWillPop() async {
    if (_loginIsOpen) {
      return false;
    } else {
      return true;
    }
  }

  bool notNull(Object o) => o != null;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: FlatButton(
            child: Text('Login'),
            onPressed: () {
              final flutterWebviewPlugin = new FlutterWebviewPlugin();

              flutterWebviewPlugin.onBack.listen((onData) async {
                if (onData == null) {
                  flutterWebviewPlugin.close();
                  setState(() {
                    _loginIsOpen = false;
                  });
                }
              });

              flutterWebviewPlugin.onUrlChanged.listen((String url) async {
                print(url);
                if (url.contains(baseurl + "auth/finish")) {
                  flutterWebviewPlugin.reloadUrl(baseurlSite);
                }

                if (url == baseurlSite) {
                  var cookies = await CookieManager.getCookies(
                      baseurl);

                  SharedPreferences prefs = await SharedPreferences.getInstance();

                  String cookieString = '';

                  // Get needed JWTToken
                  cookies.forEach((element) {
                    print(element);
                    if (element['name'] == 'knockoutJwt')
                      cookieString +=
                          element['name'] + "=" + element['value'] + "; ";
                  });

                  await prefs.setBool('isLoggedIn', true);
                  await prefs.setString('cookieString', cookieString);

                  flutterWebviewPlugin.close();
                  setState(() {
                    _loginIsOpen = false;
                  });
                }
              });

              setState(() {
                _loginIsOpen = true;
              });

              flutterWebviewPlugin.launch(
                baseurlSite + "login",
                userAgent:
                    "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
              );
            },
          ),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: _subforums.length,
          itemBuilder: (BuildContext context, int index) {
            Subforum item = _subforums[index];
            return Card(
              margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
              child: InkWell(
                onTap: () {
                  print('Clicked item ' + item.id.toString());

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SubforumScreen(
                              subforumModel: item,
                            )),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.name,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  item.description,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ]),
                        ),
                      ),
                      if (item.icon != '/static/faesbunch.png')
                        Container(
                          child: CachedNetworkImage(
                            imageUrl: item.icon,
                            width: 40.0,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
