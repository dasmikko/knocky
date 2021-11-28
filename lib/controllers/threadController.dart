import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
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

  void updateReadThread (Thread thread) {
    int lastPostNumber = thread.posts.last.threadPostNumber;
  }
}
