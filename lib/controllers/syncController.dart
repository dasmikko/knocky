import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';

class SyncController extends GetxController {
  final isFetching = false.obs;
  final subscriptionNotificationCount = 0.obs;

  static final SyncController _singleton = SyncController._internal();

  factory SyncController() {
    return _singleton;
  }

  SyncController._internal();

  void fetch() async {
    isFetching.value = true;
    var syncDataValue = await KnockoutAPI().getSyncData();

    subscriptionNotificationCount.value = syncDataValue.subscriptions
        .where((threadAlert) => threadAlert.unreadPostCount > 0)
        .length;
    print(subscriptionNotificationCount.value);

    isFetching.value = false;
  }
}
