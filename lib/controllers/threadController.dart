import 'package:get/get.dart';
import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/controllers/syncController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/syncData.dart';
import 'package:knocky/models/thread.dart';

class ThreadController extends PaginatedController<Thread> {
  @override
  Future fetchData() async {
    data.value = await KnockoutAPI().getThread(id, page: page);
    updateReadThread(data.value);
  }

  @override
  get pageCount =>
      ((data.value?.totalPosts ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  get title => data.value?.title;

  @override
  int get dataInPageCount => data.value?.posts?.length ?? 0;

  @override
  dynamic dataAtIndex(int index) => data.value?.posts[index];

  void updateReadThread(Thread thread) async {
    //int lastPostNumber = thread.posts.last.threadPostNumber;
    DateTime lastPostDate = data.value.posts.last.createdAt;

    // Check if last read is null
    if (data.value.readThreadLastSeen == null) {
      await KnockoutAPI().readThreads(lastPostDate, data.value.id).then((res) {});
    } else if (data.value.readThreadLastSeen.isBefore(lastPostDate)) {
      await KnockoutAPI().readThreads(lastPostDate, data.value.id).then((res) {});
    }

    if (data.value.subscribed == true) {
      // Handle for subscribed thread
      // Check if last read is null
      if (data.value.subscriptionLastPostNumber == null ||
          data.value.subscriptionLastPostNumber <
              data.value.posts.last.threadPostNumber) {
        await KnockoutAPI()
            .readThreadSubsciption(
                data.value.posts.last.createdAt, data.value.id)
            .then((res) {});
      }
    } else {
      if (data.value.subscriptionLastSeen == null) {
        await KnockoutAPI()
            .readThreads(lastPostDate, data.value.id)
            .then((res) {});
      }
    }

    SyncController syncController = Get.put(SyncController());
    syncController.fetch();

    // Handle mentions too!
    final List<SyncDataMentionModel> mentions = syncController.mentions;

    List<int> mentionsPostIds = mentions.map((o) => o.postId).toList();
    List<int> threadPostIds = data.value.posts.map((o) => o.id).toList();
    List<int> idsToMarkRead = [];

    mentionsPostIds.forEach((postId) {
      if (threadPostIds.contains(postId)) {
        idsToMarkRead.add(postId);
      }
    });

    if (idsToMarkRead.length > 0) {
      syncController.fetch();
    }
  }
}
