import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/events.dart';

class EventController extends GetxController {
  final isFetching = false.obs;
  final RxList<KnockoutEvent> events = <KnockoutEvent>[].obs;

  @override
  onInit() {
    super.onInit();
  }

  initState(int id, int page) {
    events.value = [];
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    events.value = (await KnockoutAPI().getEvents())!;
    isFetching.value = false;
  }
}
