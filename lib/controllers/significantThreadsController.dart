import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/significantThreads.dart';
import 'package:knocky/models/v2/thread.dart';

class SignificantThreadsController extends GetxController {
  final isFetching = false.obs;
  final RxList<SubforumThread> threads = <SubforumThread>[].obs;
  SignificantThreads _threadsToFetch = SignificantThreads.Popular;

  void fetch() async {
    isFetching.value = true;
    threads.value =
        (await KnockoutAPI().getSignificantThreads(_threadsToFetch))!;
    isFetching.value = false;
  }

  initState(SignificantThreads threadsToFetch) {
    threads.value = [];
    _threadsToFetch = threadsToFetch;
    fetch();
  }

  toggleType() {
    threads.value = [];
    this._threadsToFetch = this._threadsToFetch == SignificantThreads.Popular
        ? SignificantThreads.Latest
        : SignificantThreads.Popular;
    fetch();
  }

  String get threadsToFetchName => _threadsToFetch.name;
  SignificantThreads get threadsToFetch => _threadsToFetch;
}
