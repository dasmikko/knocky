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

  login(int userId, String username, String avatar, String background,
      int usergroup, String jwt) {
    this.userId.value = userId;
    this.username.value = username;
    this.avatar.value = avatar;
    this.background.value = background;
    this.usergroup.value = usergroup;
    this.isAuthenticated.value = true;
    this.jwt.value = jwt;

    GetStorage prefs = GetStorage();
    prefs.write('isAuthenticated', this.isAuthenticated.value);
    prefs.write('userId', userId);
    prefs.write('username', username);
    prefs.write('avatar', avatar);
    prefs.write('background', background);
    prefs.write('usergroup', usergroup);
    prefs.write('cookieString', jwt);
  }

  logout() {
    this.isAuthenticated.value = false;
    this.userId.value = 0;
    this.username.value = '';
    this.avatar.value = '';
    this.background.value = '';
    this.usergroup.value = 0;
    this.jwt.value = '';

    GetStorage prefs = GetStorage();
    prefs.write('isAuthenticated', false);
    prefs.write('userId', 0);
    prefs.write('username', '');
    prefs.write('avatar', '');
    prefs.write('background', '');
    prefs.write('usergroup', 0);
    prefs.write('cookieString', '');

    Get.snackbar('Success', 'You are now logged out');
  }
}
