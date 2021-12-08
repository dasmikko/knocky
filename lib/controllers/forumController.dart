import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/motd.dart';
import 'package:knocky/models/subforum.dart';

class ForumController extends GetxController {
  final isFetching = false.obs;
  final subforums = <Subforum>[].obs;
  final motd = <KnockoutMotd>[].obs;

  void fetchSubforums() async {
    isFetching.value = true;
    subforums.value = await KnockoutAPI().getSubforums();
    isFetching.value = false;
  }

  void fetchMotd() async {
    motd.value = await KnockoutAPI().motd();
  }
}
