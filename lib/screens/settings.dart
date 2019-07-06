import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:knocky/screens/Settings/filter.dart';

import 'package:knocky/themes/DefaultTheme.dart';
import 'package:knocky/themes/DarkTheme.dart';


class SettingsScreen extends StatefulWidget {
  BuildContext appContext;
  

  SettingsScreen({
    @required this.appContext
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeData selectedTheme = DarkTheme();

  @override
  void initState() {
    super.initState();

    if (DynamicTheme.of(context).brightness == Brightness.light) {
      selectedTheme = DefaultTheme();
    } else {
      selectedTheme = DarkTheme();
    }

  }

  void onSelectTheme (dynamic theme) {
    DynamicTheme.of(context).setBrightness(theme.brightness);
    DynamicTheme.of(context).setThemeData(theme);

    setState(() {
     selectedTheme = theme; 
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
              title: Text('Filter'),
              subtitle: Text('Select what content to filter'),
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