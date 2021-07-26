import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/userProfilePosts.dart';
import 'package:knocky/controllers/paginatedController.dart';

class ProfilePostController extends PaginatedController<UserProfilePosts> {
  @override
  Future fetchData() async {
    data.value = await KnockoutAPI().getUserPosts(id, page: page);
  }

  @override
  get pageCount =>
      ((data.value?.totalPosts ?? 0) / PostsPerPage.POSTS_PER_PAGE).ceil();

  @override
  int get dataInPageCount => data.value?.posts?.length ?? 0;

  @override
  dynamic dataAtIndex(int index) => data.value?.posts[index];
}
