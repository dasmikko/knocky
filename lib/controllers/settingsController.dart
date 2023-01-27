import 'package:get/get.dart';

class SettingsController extends GetxController {
  final String defaultAPIURL = 'https://knockyauth.rekna.xyz/';
  var apiEnv = 'knockout'.obs;
  final showNSFWThreads = false.obs;
  RxString apiEndpoint = 'https://knockyauth.rekna.xyz/'.obs;
}
