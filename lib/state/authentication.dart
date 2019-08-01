import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/helpers/api.dart';

class AuthenticationModel extends Model {
  BuildContext buildContext;

  bool _isLoggedIn = false;
  int _userId = 0;
  String _username = 'Not logged in';
  String _avatar = '';
  String _background = '';
  int _usergroup = 0;
  String _cookieString = '';
  bool _isBanned = false;
  String _banMessage = '';
  int _banThreadId = 0;

  AuthenticationModel({this.buildContext});


  bool get isLoggedIn => _isLoggedIn;
  int get userId => _userId;
  String get username => _username;
  String get avatar => _avatar;
  String get background => _background;
  int get usergroup => _usergroup;
  String get cookieString => _cookieString;
  bool get isBanned => _isBanned;
  String get banMessage => _banMessage;
  int get banThreadId => _banThreadId;

  // Get the stored auth state
  void getLoginStateFromSharedPreference(BuildContext context) async {
    Box box = await AppHiveBox.getBox();
    _isLoggedIn = await box.get('isLoggedIn', defaultValue: false);
    _userId = await box.get('userId');
    _username = await box.get('username');
    _avatar = await box.get('avatar_url');
    _background = await box.get('background_url');
    _usergroup = await box.get('usergroup');
    _cookieString = await box.get('cookieString');

    authCheck();
    notifyListeners();
  }

  // Change the login state
  Future<void> setLoginState(bool isLoggedIn, int userId, String username, String avatar, String background, int usergroup) async {
    _isLoggedIn = isLoggedIn;
    _userId = userId;
    _username = username;
    _avatar = avatar;
    _background = background;
    _usergroup = usergroup;

    Box box = await AppHiveBox.getBox();
    await box.put('isLoggedIn', isLoggedIn);
    await box.put('userId', userId);
    await box.put('username', username);
    await box.put('avatar_url', avatar);
    await box.put('background_url', background);
    await box.put('usergroup', usergroup);

    notifyListeners();
  }

  Future<void> setCookieString (String cookieString) async {
    Box box = await AppHiveBox.getBox();
    await box.put('cookieString', cookieString);
    notifyListeners();
  }

  void logout () async {
    await this.setCookieString('');
    await this.setLoginState(false, 0, '', '', '', 0);
    notifyListeners();
  }

  void authCheck () async {
    dynamic authState = await KnockoutAPI().authCheck();

    if (authState is String) {
      // Is logged in aka, OK
    }

    if (authState is Map) {
      _isBanned = false;
      _banMessage = '';
      _banThreadId = 0;

      if (authState['message'] == 'Invalid credentials. Please log out and try again.') this.logout();
      if (authState['banMessage'] != null) {
        _isBanned = true;
        _banMessage = authState['banMessage'];
        _banThreadId = authState['threadId'];
        this.logout();
      }
    }
  }

  static AuthenticationModel of(BuildContext context) {
    return ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true);
  }

}
