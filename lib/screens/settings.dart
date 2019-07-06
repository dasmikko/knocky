import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:knocky/screens/Settings/filter.dart';


class SettingsScreen extends StatefulWidget {
  BuildContext appContext;

  SettingsScreen({
    @required this.appContext
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isUsingDarkTheme;

  @override
  void initState() {
    super.initState();

    _isUsingDarkTheme = DynamicTheme.of(context).brightness == Brightness.dark? true : false;
  }

  bool updateDarkThemeSetting() {
    DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
    DynamicTheme.of(context).setThemeData(new ThemeData(
        primarySwatch: Colors.red,
        brightness: Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark,
        accentColor: Theme.of(context).brightness == Brightness.dark? Colors.red : Colors.red
    ));

    setState(() {
     _isUsingDarkTheme = Theme.of(context).brightness == Brightness.dark? false : true;
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
            SwitchListTile(
              title: Text('Dark theme'),
              subtitle: Text('Enable the dark theme for when\nusing the app at night.'),
              onChanged: (bool value) {
                this.updateDarkThemeSetting();
              },
              value: _isUsingDarkTheme,
            ),
            ListTile(
              title: Text('Filter'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterScreen()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}