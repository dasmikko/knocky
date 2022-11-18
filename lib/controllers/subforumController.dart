import 'package:get/get.dart';
import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/subforumv2.dart';

class SubforumController extends PaginatedController<Subforum> {
  final isFetching = false.obs;

  @override
  Future fetchData() async {
    isFetching.value = true;
    data.value = await KnockoutAPI().getSubforumDetails(id, page: page);
    isFetching.value = false;
  }

  @override
  get pageCount =>
      ((data.value?.totalThreads ?? 0) / PostsPerPage.SUBFORUM_POSTS_PER_PAGE)
          .ceil();

  get title => data.value?.name;

  @override
  int get dataInPageCount => data.value?.threads?.length ?? 0;

  @override
  dynamic dataAtIndex(int index) => data.value?.threads[index];
}
