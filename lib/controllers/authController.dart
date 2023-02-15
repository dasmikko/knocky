import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/v2/user.dart';
import 'package:knocky/models/v2/userRole.dart';

class AuthController extends GetxController {
  var isAuthenticated = false.obs;
  var jwt = ''.obs;
  var userId = 0.obs;
  var username = ''.obs;
  var avatar = ''.obs;
  var background = ''.obs;
  var usergroup = 0.obs;
  Rx<UserRole?> role = UserRole().obs;

  getStoredAuthInfo() {
    GetStorage prefs = GetStorage();
    if (prefs.read('isAuthenticated') != null &&
        prefs.read('isAuthenticated')) {
      this.isAuthenticated.value = true;
      this.jwt.value = prefs.read('jwt');
      this.userId.value = prefs.read('userId');
      this.username.value = prefs.read('username');
      this.avatar.value = prefs.read('avatar');
      this.background.value = prefs.read('background');
      this.role.value = UserRole.fromJson(prefs.read('role'));
    }
  }

  login(int userId, String username, String avatar, String background,
      int usergroup, UserRole role, String jwt) {
    this.userId.value = userId;
    this.username.value = username;
    this.avatar.value = avatar;
    this.background.value = background;
    this.isAuthenticated.value = true;
    this.jwt.value = jwt;

    GetStorage prefs = GetStorage();
    prefs.write('isAuthenticated', this.isAuthenticated.value);
    prefs.write('userId', userId);
    prefs.write('username', username);
    prefs.write('avatar', avatar);
    prefs.write('background', background);
    prefs.write('jwt', jwt);

    prefs.write('role', role);
  }

  loginWithJWTOnly(jwtToken) async {
    GetStorage prefs = GetStorage();
    this.isAuthenticated.value = true;
    await prefs.write('isAuthenticated', this.isAuthenticated.value);
    await prefs.write('jwt', jwtToken);
    this.jwt.value = jwtToken;

    try {
      SyncDataModel syncData = await KnockoutAPI().getSyncData();
      print(syncData.toJson());
      prefs.write('userId', syncData.id);
      prefs.write('username', syncData.username);
      prefs.write('avatar', syncData.avatarUrl);
      prefs.write('background', syncData.backgroundUrl);
      prefs.write('role', syncData.role!.toJson());

      this.userId.value = syncData.id!;
      this.username.value = syncData.username!;
      this.avatar.value = syncData.avatarUrl!;
      this.background.value = syncData.backgroundUrl!;
      this.role.value = syncData.role;
    } catch (err) {
      print(err);
      logout();
      throw (err);
    }
  }

  logout({bool noSnackBar = false}) {
    this.isAuthenticated.value = false;
    this.userId.value = 0;
    this.username.value = '';
    this.avatar.value = '';
    this.background.value = '';
    this.jwt.value = '';
    this.role.value = UserRole();

    GetStorage prefs = GetStorage();
    prefs.write('isAuthenticated', false);
    prefs.write('userId', 0);
    prefs.write('username', '');
    prefs.write('avatar', '');
    prefs.write('background', '');
    prefs.write('cookieString', '');
    prefs.write('jwt', '');
    prefs.write('role', UserRole().toJson());

    if (!noSnackBar) KnockySnackbar.success('You are now logged out');
  }
}
