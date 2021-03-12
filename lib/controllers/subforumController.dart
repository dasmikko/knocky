import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforumDetails.dart';

class SubforumController extends GetxController {
  final isFetching = false.obs;
  final subforum = SubforumDetails().obs;

  void fetchSubforum(id) async {
    isFetching.value = true;
    subforum.value = await KnockoutAPI().getSubforumDetails(id);
    isFetching.value = false;
  }
}
