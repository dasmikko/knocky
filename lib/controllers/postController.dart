import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/userProfilePosts.dart';

class ProfilePostController extends GetxController {
  final isFetching = false.obs;
  final thread = UserProfilePosts().obs;
  final _page = 1.obs;
  int id;

  @override
  onInit() {
    super.onInit();
    ever(_page, (_) => fetch());
  }

  initState(int id, int page) {
    thread.value = null;
    this.id = id;
    _page.value = page;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    thread.value = await KnockoutAPI().getUserPosts(id, page: page);
    isFetching.value = false;
  }

  get page => _page.value;

  get pageCount =>
      ((thread.value?.totalPosts ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  nextPage() => _page.value++;

  previousPage() => _page.value--;

  goToPage(pageNumber) => _page.value = pageNumber;
}
