import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/screens/Settings/filter.dart';
import 'package:knocky/themes/DefaultTheme.dart';
import 'package:knocky/themes/DarkTheme.dart';
import 'package:package_info/package_info.dart';
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
  ThemeData selectedTheme = darkTheme();
  String selectedEnv = 'knockout';
  String _version = '';
  bool _useInlineYoutubePlayer = true;

  @override
  void initState() {
    super.initState();

    updateAppInfo();
    getEmbedSettings();

    if (DynamicTheme.of(context).brightness == Brightness.light) {
      selectedTheme = defaultTheme();
    } else {
      selectedTheme = darkTheme();
    }
  }

  void getEmbedSettings () async {
    // Init hive
    Box box = await AppHiveBox.getBox();

    setState(() {
     _useInlineYoutubePlayer = box.get('useInlineYoutubePlayer', defaultValue: true);
    });
  }

  void updateAppInfo () async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Box box = await AppHiveBox.getBox();
    String env = await box.get('env');

    setState(() {
     _version = packageInfo.version;
     selectedEnv = env;
    });
  }

  void onSelectTheme (dynamic theme) {
    DynamicTheme.of(context).setBrightness(theme.brightness);
    DynamicTheme.of(context).setThemeData(theme);

    if (theme.brightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.grey[900],
              systemNavigationBarIconBrightness: Brightness.light));
    }

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

              Box box = await AppHiveBox.getBox();
              await box.put('env', env);

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
              title: Text('General', style: TextStyle(color: Colors.grey),),
              dense: true,
            ),
            ListTile(
              enabled: true,
              title: Text('Theme'),
              trailing: DropdownButton(
                value: selectedTheme,
                onChanged: onSelectTheme,
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text('Light theme'),
                    value: defaultTheme(),
                  ),
                  DropdownMenuItem(
                    child: Text('Dark theme'),
                    value: darkTheme(),
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
            Divider(
              color: Colors.grey,
            ),
            ListTile(
              title: Text('Embed settings', style: TextStyle(color: Colors.grey),),
              dense: true,
            ),
            SwitchListTile(
              activeColor: AppColors(context).switchColor(),
              title: Text('Use inline YouTube player'),
              subtitle: Text('When disabled, it will try to open app that can handle the YouTube link.'),
              onChanged: (bool value) async {
                Box box = await AppHiveBox.getBox();
                box.put('useInlineYoutubePlayer', value);
                setState(() {
                 _useInlineYoutubePlayer = value;
                });
              },
              value: _useInlineYoutubePlayer,
            ),
            Divider(
              color: Colors.grey,
            ),
            ListTile(
              title: Text('App info', style: TextStyle(color: Colors.grey),),
              dense: true,
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