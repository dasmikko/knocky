import 'package:knocky/controllers/paginatedController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/userProfileThreads.dart';

class ProfileThreadController extends PaginatedController<UserProfileThreads> {
  @override
  Future fetchData() async {
    data.value = await KnockoutAPI().getUserThreads(id, page: page);
  }

  @override
  int get pageCount =>
      ((data.value!.totalThreads ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  @override
  int get dataInPageCount => data.value!.threads!.length ?? 0;

  @override
  dynamic dataAtIndex(int index) => data.value!.threads![index];
}
