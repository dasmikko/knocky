import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/threadAlert.dart';

class SubscriptionController extends GetxController {
  final isFetching = false.obs;
  final subscriptions = <ThreadAlert>[].obs;

  void fetch() async {
    isFetching.value = true;
    subscriptions.value = await KnockoutAPI().getAlerts();
    isFetching.value = false;
  }
}
