import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfileDetails.dart';

class ProfileController extends GetxController {
  final isFetching = false.obs;
  final profile = UserProfile().obs;
  final details = UserProfileDetails().obs;
  final ratings = [].obs;
  int id;

  @override
  onInit() {
    super.onInit();
  }

  initState(int id) {
    this.id = id;
    profile.value = null;
    details.value = null;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    profile.value = await KnockoutAPI().getUserProfile(this.id);
    details.value = await KnockoutAPI().getUserProfileDetails(this.id);
    ratings.value = await KnockoutAPI().getUserProfileTopRatings(this.id);
    isFetching.value = false;
  }
}
