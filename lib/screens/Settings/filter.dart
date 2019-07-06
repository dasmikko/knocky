import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart';


class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _showNSFWThreads = false;

  @override
  void initState() {
    super.initState();

    this.refreshSettings();
  }

  void refreshSettings () async {
   SharedPreferences prefs = await SharedPreferences.getInstance();

   setState(() {
    _showNSFWThreads = prefs.getBool('showNSFWThreads') != null ? prefs.getBool('showNSFWThreads') : false; 
   });
    
    
  }

  void updateNSFWSettings (bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showNSFWThreads', val);

    setState(() {
      _showNSFWThreads = val;
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
              title: Text('Show NSFW threads'),
              subtitle: Text('Enable this if you are a naughty boy.'),
              onChanged: (bool value) {
                this.updateNSFWSettings(value);
              },
              value: _showNSFWThreads,
            ),
          ],
        ),
      ),
    );
  }
}