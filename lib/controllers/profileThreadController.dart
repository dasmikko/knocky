import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/userProfileThreads.dart';

class ProfileThreadController extends GetxController {
  final isFetching = false.obs;
  final threads = UserProfileThreads().obs;
  final _page = 1.obs;
  int id;

  @override
  onInit() {
    super.onInit();
    ever(_page, (_) => fetch());
  }

  initState(int id, int page) {
    threads.value = null;
    this.id = id;
    _page.value = page;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    threads.value = await KnockoutAPI().getUserThreads(id, page: page);
    isFetching.value = false;
  }

  get page => _page.value;

  get pageCount =>
      ((threads.value?.totalThreads ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  nextPage() => _page.value++;

  previousPage() => _page.value--;

  goToPage(pageNumber) => _page.value = pageNumber;
}
