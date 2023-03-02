import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BlockedUsersController extends GetxController {
  var blockedUserIds = <dynamic>[].obs;

  void addBlockedUserId(int userId) {
    blockedUserIds.add(userId);
    updateStorage();
  }

  void removeBlockedUserId(int userId) {
    blockedUserIds.removeWhere((element) => element == userId);
    updateStorage();
  }

  void clearBlockedUserIds() {
    blockedUserIds.clear();
    updateStorage();
  }

  void updateStorage() {
    GetStorage prefs = GetStorage();
    prefs.write('blockedUserIds', blockedUserIds.value);
  }

  void initBlockedUsers() {
    GetStorage prefs = GetStorage();

    if (prefs.read('blockedUserIds') != null) {
      blockedUserIds.value = prefs.read('blockedUserIds');
    }
  }

  bool userIsBlocked(userId) => blockedUserIds.contains(userId);
}
