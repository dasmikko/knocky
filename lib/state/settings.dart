import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends Model {
  String _env = 'knockout';
  String get env => _env;

  // Get the stored auth state
  void getSettingsSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _env = prefs.getString('env');
    notifyListeners();
  }

  void updateEnv (String env) {
    _env = env;
    notifyListeners();
  }

  static SettingsModel of(BuildContext context) =>
    ScopedModel.of<SettingsModel>(context, rebuildOnChange: true);
}
