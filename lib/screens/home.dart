import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/screens/settings.dart';
import 'package:knocky/widget/Drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AfterLayoutMixin<HomeScreen> {
  List<Subforum> _subforums = new List<Subforum>();
  bool _loginIsOpen;

  void initState() {
    super.initState();

    _loginIsOpen = false;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    var kapi = new KnockoutAPI();

    kapi.getSubforums().then((subforums) {
      setState(() {
        _subforums = subforums;
      });
    });

    kapi.authCheck();
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
          title: Text('Knocky'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsScreen(appContext: context,)),
                  );
              },
            )
          ],
        ),
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
