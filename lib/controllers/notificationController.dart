import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/notification.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  var isFetching = false.obs;

  fetch() async {
    isFetching.value = true;
    notifications.value = (await KnockoutAPI().notifications())!;
    isFetching.value = false;
  }
}
