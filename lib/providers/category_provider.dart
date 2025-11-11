import 'package:flutter/foundation.dart';

class CategoryProvider extends ChangeNotifier {
  String _selected = '전체';
  String get selected => _selected;

  void select(String category) {
    _selected = category;
    notifyListeners();
  }
}
