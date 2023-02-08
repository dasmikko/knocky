import 'dart:async';
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
    //events.value = null;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    events.value =
        await (KnockoutAPI().getEvents() as FutureOr<List<KnockoutEvent>>);
    isFetching.value = false;
  }
}
