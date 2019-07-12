import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationModel extends Model {
  bool _isLoggedIn = false;
  int _userId = 0;
  String _username = 'Not logged in';
  String _avatar = '';
  String _background = '';
  int _usergroup = 0;

  bool get isLoggedIn => _isLoggedIn;
  int get userId => _userId;
  String get username => _username;
  String get avatar => _avatar;
  String get background => _background;
  int get usergroup => _usergroup;

  // Get the stored auth state
  void getLoginStateFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') != null
        ? prefs.getBool('isLoggedIn')
        : false;
    _userId = prefs.getInt('userId');
    _username = prefs.getString('username');
    _avatar = prefs.getString('avatar_url');
    _background = prefs.getString('background_url');
    _usergroup = prefs.getInt('usergroup');
  }

  // Change the login state
  void setLoginState(bool isLoggedIn, int userId, String username, String avatar, String background, int usergroup) {
    _isLoggedIn = isLoggedIn;
    _userId = userId;
    _username = username;
    _avatar = avatar;
    _background = background;
    _usergroup = usergroup;
    notifyListeners();
  }
}
