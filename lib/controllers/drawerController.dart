import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/ad.dart';

class MainDrawerController extends GetxController {
  var isUserListOpen = false.obs;
  var adImageUrl = ''.obs;

  fetchRandomAd() async {
    KnockoutAd ad = await KnockoutAPI().randomAd();

    adImageUrl.value = ad.imageUrl!;
  }
}
