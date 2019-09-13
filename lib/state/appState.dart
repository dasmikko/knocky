
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/syncData.dart';
import 'package:scoped_model/scoped_model.dart';


class AppStateModel extends Model {
  int _currentTab = 0;
  int get currentTab => _currentTab;

  List<SyncDataMentionModel> _mentions = List();
  List<SyncDataMentionModel> get mentions => _mentions;

  int mentionsCount () {
    return _mentions.length;
  }

  void setCurrentTab (int index) {
    _currentTab = index;
    notifyListeners();
  }

  void updateSyncData () async {
    SyncDataModel syncData = await KnockoutAPI().getSyncData();
    _mentions = syncData.mentions;
    print(syncData.toJson());
    notifyListeners();
  }
}