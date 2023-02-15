import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/controllers/syncController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/thread.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ThreadController extends PaginatedController<Thread> {
  final AuthController authController = Get.put(AuthController());
  final SyncController syncController = Get.put(SyncController());
  ItemScrollController itemScrollController = new ItemScrollController();
  final currentNewPostText = ''.obs;
  final replyToAdd = ''.obs;
  final hideFAB = false.obs;

  @override
  Future fetchData() async {
    Thread newData = await KnockoutAPI().getThread(id, page: page);
    data.value = null; // Force clean up?
    clearMemoryImageCache();
    data.value = newData;

    hideFAB.value = false;

    if (authController.isAuthenticated.value) {
      updateAlerts(data.value!);
      updateReadThread(data.value!);
      handleNotifications(data.value!);
    }
  }

  @override
  get pageCount =>
      ((data.value!.totalPosts ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  get title => data.value?.title;

  @override
  int get dataInPageCount => data.value!.posts!.length ?? 0;

  @override
  dynamic dataAtIndex(int index) => data.value!.posts![index];

  void updateAlerts(Thread thread) async {
    int? lastPostNumber = thread.posts!.last.threadPostNumber;

    if (thread.subscribed!) {
      if (thread.subscriptionLastPostNumber! < lastPostNumber!) {
        await KnockoutAPI().createAlert(thread.id, lastPostNumber);
      }
    }
  }

  void updateReadThread(Thread thread) async {
    DateTime lastPostDate = thread.posts!.last.createdAt!;
    if (thread.readThreadLastSeen == null ||
        thread.readThreadLastSeen!.isBefore(lastPostDate)) {
      await KnockoutAPI().readThreads(lastPostDate, thread.id);
    }
  }

  void handleNotifications(Thread thread) {
    // Handle mentions too!
    List<SyncDataMentionModel> mentions = syncController.mentions;

    List<int?> mentionsPostIds = mentions.map((o) => o.postId).toList();
    List<int?> threadPostIds = thread.posts!.map((o) => o.id).toList();
    List<int?> idsToMarkRead = [];

    mentionsPostIds.forEach((postId) {
      if (threadPostIds.contains(postId)) {
        idsToMarkRead.add(postId);
      }
    });

    if (idsToMarkRead.length > 0) {
      KnockoutAPI().markMentionsAsRead(idsToMarkRead).then((wasMarkedRead) {
        syncController.fetch();
      });
    }
  }
}
