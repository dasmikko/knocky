import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/models/forum.dart';
import 'package:knocky/models/motd.dart';

class ForumController extends GetxController {
  final isFetching = false.obs;
  final RxList<Subforum> subforums = <Subforum>[].obs;
  final RxList<KnockoutMotd> motd = <KnockoutMotd>[].obs;
  final hiddenMotds = [].obs;

  void initHiddenMotds() {
    GetStorage storage = GetStorage();
    hiddenMotds.value = storage.hasData('hiddenMotds')
        ? storage.read('hiddenMotds')
        : <dynamic>[];
  }

  void fetchSubforums() async {
    isFetching.value = true;
    try {
      Forum forum = await KnockoutAPI().getSubforums();
      subforums.value = forum.list!;
      isFetching.value = false;
    } catch (e) {
      print(e);
      isFetching.value = false;
      KnockySnackbar.error("Failed loading subforums");
    }
  }

  bool motdIsHidden(motdId) => hiddenMotds.contains(motdId);

  void fetchMotd() async {
    motd.value = (await KnockoutAPI().motd())!;
    initHiddenMotds();
  }
}
