import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/thread.dart';

class ThreadController extends GetxController {
  final isFetching = false.obs;
  final thread = Thread().obs;

  void fetchThreadPage(int id, {int page: 1}) async {
    isFetching.value = true;
    thread.value = await KnockoutAPI().getThread(id, page: page);
    isFetching.value = false;
  }
}
