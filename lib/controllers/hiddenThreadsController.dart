import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/v2/alerts.dart';
import 'package:knocky/models/v2/thread.dart';

class HiddenThreadsController extends GetxController {
  final isFetching = false.obs;
  final RxList<ForumThread> threads = <ForumThread>[].obs;

  @override
  onInit() {
    super.onInit();
  }

  initState() {
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    // Get hidden threads
    threads.value = await KnockoutAPI().hiddenThreads();
    isFetching.value = false;
  }
}
