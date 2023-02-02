import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/userBans.dart';

class BansController extends GetxController {
  final isFetching = false.obs;
  final Rx<UserBans?> bans = UserBans().obs;
  int? id;

  @override
  onInit() {
    super.onInit();
  }

  initState(int? id) {
    this.id = id;
    bans.value = null;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    bans.value = await KnockoutAPI().getUserBans(this.id);
    isFetching.value = false;
  }
}
