import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') != null
        ? prefs.getBool('isLoggedIn')
        : false;
    _userId = prefs.getInt('userId');
    _username = prefs.getString('username');
    _avatar = prefs.getString('avatar_url');
    _background = prefs.getString('background_url');
    _usergroup = prefs.getInt('usergroup');
    _cookieString = prefs.getString('cookieString');

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('avatar_url', avatar);
    await prefs.setString('background_url', background);
    await prefs.setInt('usergroup', usergroup);

    notifyListeners();
  }

  Future<void> setCookieString (String cookieString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookieString', cookieString);
    notifyListeners();
  }

  void logout () async {
    await this.setCookieString('');
    await this.setLoginState(false, 0, '', '', '', 0);
    notifyListeners();
  }

  void authCheck () async {
    dynamic authState = await KnockoutAPI().authCheck();
    print(authState);

    if (authState is String) {
      print('is string');
      print(authState);
    }

    if (authState is Map) {
      print('is map');
      print(authState['message']);

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
