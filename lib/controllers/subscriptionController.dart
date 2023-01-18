import 'package:get/get.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/postsPerPage.dart';
import 'package:knocky/models/v2/alerts.dart';

class SubscriptionController extends GetxController {
  final isFetching = false.obs;
  final subscriptions = Alerts().obs;
  final _page = 1.obs;

  @override
  onInit() {
    super.onInit();
    ever(_page, (_) => fetch());
  }

  initState() {
    subscriptions.value = new Alerts(alerts: [], totalAlerts: 0);
    _page.value = 1;
    fetch();
  }

  void fetch() async {
    isFetching.value = true;
    subscriptions.value = await KnockoutAPI().getAlertsPaginated(page: page);
    isFetching.value = false;
  }

  get page => _page.value;

  get pageCount =>
      ((subscriptions.value?.totalAlerts ?? 0) / PostsPerPage.POSTS_PER_PAGE)
          .ceil();

  nextPage() => _page.value++;

  previousPage() => _page.value--;

  goToPage(pageNumber) => _page.value = pageNumber;
}
