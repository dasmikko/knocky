import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/syncData.dart';

class SyncController extends GetxController {
  final isFetching = false.obs;
  final subscriptionNotificationCount = 0.obs;
  final mentions = <SyncDataMentionModel>[].obs;

  static final SyncController _singleton = SyncController._internal();

  factory SyncController() {
    return _singleton;
  }

  SyncController._internal();

  void fetch() async {
    isFetching.value = true;
    var syncDataValue = await KnockoutAPI().getSyncData();

    if (syncDataValue.subscriptions != null) {
      subscriptionNotificationCount.value = syncDataValue.subscriptions
          .where((threadAlert) => threadAlert.unreadPostCount > 0)
          .length;
    }

    mentions.value = syncDataValue.mentions;

    isFetching.value = false;
  }
}
