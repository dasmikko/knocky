import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  var isAuthenticated = false.obs;
  var jwt = ''.obs;
  var userId = 0.obs;
  var username = ''.obs;
  var avatar = ''.obs;
  var background = ''.obs;
  var usergroup = 0.obs;

  getStoredAuthInfo() {
    GetStorage prefs = GetStorage();
    if (prefs.read('isAuthenticated') != null &&
        prefs.read('isAuthenticated')) {
      this.isAuthenticated.value = true;
      this.jwt.value = prefs.read('cookieString');
      this.userId.value = prefs.read('userId');
      this.username.value = prefs.read('username');
      this.avatar.value = prefs.read('avatar');
      this.background.value = prefs.read('background');
      this.usergroup.value = prefs.read('usergroup');
    }
  }

  setLoggedInUser(int userId, String username, String avatar, String background,
      int usergroup) {
    this.userId.value = userId;
    this.username.value = username;
    this.avatar.value = avatar;
    this.background.value = background;
    this.usergroup.value = usergroup;

    GetStorage prefs = GetStorage();
    prefs.write('isAuthenticated', this.isAuthenticated.value);
    prefs.write('userId', userId);
    prefs.write('username', username);
    prefs.write('avatar', avatar);
    prefs.write('background', background);
    prefs.write('usergroup', usergroup);
  }

  setJwtToken(String token) {
    GetStorage prefs = GetStorage();
    this.jwt.value = token;
    prefs.write('cookieString', token);
  }

  logout() {
    this.isAuthenticated.value = false;
    setLoggedInUser(0, '', '', '', 0);
    setJwtToken('');
    Get.snackbar('Success', 'You are now logged out');
  }
}
