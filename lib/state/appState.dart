
import 'package:scoped_model/scoped_model.dart';

class AppStateModel extends Model {
  int _currentTab = 0;
  int get currentTab => _currentTab;

  void setCurrentTab (int index) {
    _currentTab = index;
    notifyListeners();
  }
}