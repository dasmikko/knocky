import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/thread.dart';

class ThreadController extends GetxController {
  final isFetching = false.obs;
  final thread = Thread().obs;
  final _page = 1.obs;
  int id;

  @override
  onInit() {
    super.onInit();
    ever(_page, (_) => fetch());
  }

  initState(int id, int page) {
    this.id = id;
    _page.value = page;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    thread.value = await KnockoutAPI().getThread(id, page: page);
    isFetching.value = false;
  }

  get page => _page.value;
  nextPage() => _page.value++;
  previousPage() => _page.value--;
  goToPage(pageNumber) => _page.value = pageNumber;
}
