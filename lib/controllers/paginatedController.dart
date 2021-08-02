import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PaginatedController<T> extends GetxController {
  final isFetching = false.obs;
  final _page = 1.obs;
  final data = Rx<T>(null);
  int id;

  @override
  onInit() {
    super.onInit();
    ever(_page, (_) => fetch());
  }

  @protected
  Future fetchData() async {}

  dynamic dataAtIndex(int index) => null;

  int get pageCount => 0;

  int get dataInPageCount => 0;

  initState(int id, int page) {
    data.value = null;
    this.id = id;
    _page.value = page;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    await fetchData();
    isFetching.value = false;
  }

  get page => _page.value;

  nextPage() => _page.value++;

  previousPage() => _page.value--;

  goToPage(pageNumber) => _page.value = pageNumber;
}
