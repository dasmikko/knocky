import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:knocky/screens/Settings/filter.dart';
import 'package:knocky/themes/DefaultTheme.dart';
import 'package:knocky/themes/DarkTheme.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:scoped_model/scoped_model.dart';


class SettingsScreen extends StatefulWidget {
  final BuildContext appContext;


  SettingsScreen({
    @required this.appContext
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeData selectedTheme = DarkTheme();
  String selectedEnv = 'knockout';
  String _version = '';

  @override
  void initState() {
    super.initState();

    updateAppInfo();

    if (DynamicTheme.of(context).brightness == Brightness.light) {
      selectedTheme = DefaultTheme();
    } else {
      selectedTheme = DarkTheme();
    }

    //selectedEnv = ScopedModel.of<SettingsModel>(context).env;


  }

  void updateAppInfo () async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
     _version = packageInfo.version;
     selectedEnv = prefs.getString('env');
    });
  }

  void onSelectTheme (dynamic theme) {
    DynamicTheme.of(context).setBrightness(theme.brightness);
    DynamicTheme.of(context).setThemeData(theme);

    setState(() {
     selectedTheme = theme;
    });
  }

  void onSelectEnv (dynamic env) async {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Are you sure?'),
        content: Text('If you switch environment, you will be logged out.'),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () async {
              setState(() {
                selectedEnv = env;
              });

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('env', env);
              ScopedModel.of<AuthenticationModel>(context).logout();
              ScopedModel.of<SubscriptionModel>(context).clearList();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          children: <Widget>[
            ListTile(
              enabled: true,
              title: Text('Theme'),
              trailing: DropdownButton(
                value: selectedTheme,
                onChanged: onSelectTheme,
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text('Light theme'),
                    value: DefaultTheme(),
                  ),
                  DropdownMenuItem(
                    child: Text('Dark theme'),
                    value: DarkTheme(),
                  )
                ],
              ),

            ),
            ListTile(
              enabled: true,
              title: Text('Environment'),
              trailing: DropdownButton(
                value: selectedEnv,
                onChanged: onSelectEnv,
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text('Knockout'),
                    value: 'knockout',
                  ),
                  DropdownMenuItem(
                    child: Text('QA'),
                    value: 'qa',
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Filter'),
              subtitle: Text('Select what content to filter'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Version'),
              subtitle: Text(_version),
            )
          ],
        ),
      ),
    );
  }
}