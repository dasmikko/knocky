import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/thread.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ThreadController extends PaginatedController<Thread> {
  final AuthController authController = Get.put(AuthController());
  final ItemScrollController itemScrollController = new ItemScrollController();
  final currentNewPostText = ''.obs;
  final hideFAB = false.obs;

  @override
  Future fetchData() async {
    data.value = await KnockoutAPI().getThread(id, page: page);

    hideFAB.value = false;

    if (authController.isAuthenticated.value) {
      updateAlerts(data.value);
      updateReadThread(data.value);
    }
  }

  @override
  get pageCount =>
      ((data.value?.totalPosts ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  get title => data.value?.title;

  @override
  int get dataInPageCount => data.value?.posts?.length ?? 0;

  @override
  dynamic dataAtIndex(int index) => data.value?.posts[index];

  void updateAlerts(Thread thread) async {
    int lastPostNumber = thread.posts.last.threadPostNumber;

    if (thread.subscribed) {
      if (thread.subscriptionLastPostNumber == null ||
          thread.subscriptionLastPostNumber < lastPostNumber) {
        await KnockoutAPI().createAlert(thread.id, lastPostNumber);
      }
    }
  }

  void updateReadThread(Thread thread) async {
    DateTime lastPostDate = thread.posts.last.createdAt;
    if (thread.readThreadLastSeen == null ||
        thread.readThreadLastSeen.isBefore(lastPostDate)) {
      await KnockoutAPI().readThreads(lastPostDate, thread.id);
    }
  }
}
