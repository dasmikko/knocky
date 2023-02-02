import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/thread.dart';

class RatingsController extends GetxController {
  Future<List<ThreadPostRating>?> getRatingsOf(postId) async {
    var post = await KnockoutAPI().getPost(postId);
    return post.ratings;
  }
}
