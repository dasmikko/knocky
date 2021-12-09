import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/motd.dart';
import 'package:knocky/models/subforum.dart';

class ForumController extends GetxController {
  final isFetching = false.obs;
  final subforums = <Subforum>[].obs;
  final motd = <KnockoutMotd>[].obs;
  final hiddenMotds = [].obs;

  void initHiddenMotds() {
    GetStorage storage = GetStorage();
    hiddenMotds.value = storage.hasData('hiddenMotds')
        ? storage.read('hiddenMotds')
        : <dynamic>[];
  }

  void fetchSubforums() async {
    isFetching.value = true;
    subforums.value = await KnockoutAPI().getSubforums();
    isFetching.value = false;
  }

  bool motdIsHidden(motdId) => hiddenMotds.contains(motdId);

  void fetchMotd() async {
    motd.value = await KnockoutAPI().motd();
    initHiddenMotds();
  }
}
