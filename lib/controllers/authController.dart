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

  setLoggedInUser(int userId, String username, String avatar, String background,
      int usergroup) {
    this.userId.value = userId;
    this.username.value = username;
    this.avatar.value = avatar;
    this.background.value = background;
    this.usergroup.value = usergroup;
  }

  setJwtToken(String token) {
    GetStorage prefs = GetStorage();
    this.jwt.value = token;
    prefs.write('cookieString', token);
  }
}
