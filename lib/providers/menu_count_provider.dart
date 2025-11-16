import 'package:flutter/foundation.dart';

class MenuCountProvider extends ChangeNotifier {
  int _count = 1;
  int get count => _count;

  void reset(int value) {
    _count = value;
    notifyListeners();
  }

  void increase() {
    _count++;
    notifyListeners();
  }

  void decrease() {
    if (_count > 1) {
      _count--;
      notifyListeners();
    }
  }
}
