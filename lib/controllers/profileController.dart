import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/userProfile.dart';

class ProfileController extends GetxController {
  final isFetching = false.obs;
  final profile = UserProfile().obs;
  int id;

  @override
  onInit() {
    super.onInit();
  }

  initState(int id) {
    this.id = id;
    profile.value = null;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    profile.value = await KnockoutAPI().getUserProfile(this.id);
    isFetching.value = false;
  }
}
