import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_cart);

  /// - fold 사용 이유:
  ///   - 리스트를 순회하면서 누적 합계를 만들 때 for문 대신
  ///     fold를 쓰면 코드가 더 간결하고 의도가 명확해짐.
  /// - as를 쓰지 않고, toString + int.tryParse 조합을 쓰는 이유:
  ///   - count 값이 int든 String이든 안전하게 숫자로 변환하기 위함.
  ///   - 타입이 잘못 들어와도 앱이 크래시 나지 않고 0으로 처리.
  int get totalCount => _cart.fold(0, (sum, e) {
    final countValue = e['count'];
    final count = int.tryParse(countValue.toString()) ?? 0;
    return sum + count;
  });

  int get totalPrice => _cart.fold(0, (sum, e) {
    final priceValue = e['price'];
    final countValue = e['count'];

    final price = int.tryParse(priceValue.toString()) ?? 0;
    final count = int.tryParse(countValue.toString()) ?? 0;

    return sum + (price * count);
  });

  //장바구니에서 특정 아이템의 수량을 +1시키는 메서드.
  void addItem(Map<String, dynamic> item) {
    // 같은 타이틀을 가진 기존 장바구니 항목이 있는지 확인
    final index = _cart.indexWhere((e) => e['title'] == item['title']);
    if (index == -1) {
      // 처음 담는 메뉴라면 → 새 항목으로 추가 + count 기본값 1로 설정
      _cart.add({...item, 'count': 1});
    } else {
      _cart[index]['count']++;
    }
    notifyListeners();
  }

  //장바구니에서 특정 아이템의 수량을 -1시키는 메서드.
  void decreaseItem(Map<String, dynamic> item) {
    final title = item['title'] as String; // Map에서 title만 뽑아서 사용
    final index = _cart.indexWhere((e) => e['title'] == title);
    if (index == -1) return;

    _cart[index]['count']--;
    if (_cart[index]['count'] <= 0) {
      _cart.removeAt(index);
    }
    notifyListeners();
  }


  //특정 메뉴의 수량을 강제로 설정하는 메서드.
  void setItemCount(String title, int count) {
    final index = _cart.indexWhere((e) => e['title'] == title);
    if (index == -1) return;
    _cart[index]['count'] = count;
    notifyListeners();
  }

  //장바구니에서 삭제하는 메서드.
  void removeItem(String title) {
    _cart.removeWhere((e) => e['title'] == title);
    notifyListeners();
  }

  //장바구니를 완전히 비우는 메서드(주문완료 후 장바구니 초기화)
  void clear() {
    _cart.clear();
    notifyListeners();
  }
}
