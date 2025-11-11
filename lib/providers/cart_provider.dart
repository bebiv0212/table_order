import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_cart);

  int get totalCount => _cart.fold(0, (sum, e) => sum + (e['count'] as int));
  int get totalPrice => _cart.fold(
    0,
    (sum, e) => sum + (e['price'] as int) * (e['count'] as int),
  );

  void addItem(Map<String, dynamic> item) {
    final index = _cart.indexWhere((e) => e['title'] == item['title']);
    if (index == -1) {
      _cart.add({...item, 'count': 1});
    } else {
      _cart[index]['count']++;
    }
    notifyListeners();
  }

  void decreaseItem(String title) {
    final index = _cart.indexWhere((e) => e['title'] == title);
    if (index == -1) return;
    _cart[index]['count']--;
    if (_cart[index]['count'] <= 0) _cart.removeAt(index);
    notifyListeners();
  }

  void setItemCount(String title, int count) {
    final index = _cart.indexWhere((e) => e['title'] == title);
    if (index == -1) return;
    _cart[index]['count'] = count;
    notifyListeners();
  }

  void removeItem(String title) {
    _cart.removeWhere((e) => e['title'] == title);
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }
}
