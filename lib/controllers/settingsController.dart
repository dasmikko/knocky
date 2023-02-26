import 'package:get/get.dart';

class SettingsController extends GetxController {
  final String defaultAPIURL = 'https://knockyauth.rekna.xyz/';
  final RxBool useDevAPI = false.obs;
  var apiEnv = 'knockout'.obs;
  final showNSFWThreads = false.obs;
  final flagPunchy = false.obs;
  RxString apiEndpoint = 'https://knockyauth.rekna.xyz/'.obs;
}
