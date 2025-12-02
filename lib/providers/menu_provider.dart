import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/models/menu_model.dart';

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  bool _loading = true;
  bool get loading => _loading;

  StreamSubscription? _menuSub;

  /// 🔥 메뉴를 실시간으로 감시
  void listenMenus(String adminUid) {
    _loading = true;
    notifyListeners();

    _menuSub = _db
        .collection('admins')
        .doc(adminUid)
        .collection('menus')
        .snapshots()
        .listen((snapshot) {
          _menus = snapshot.docs
              .map((doc) => MenuModel.fromMap(doc.data(), doc.id))
              .toList();

          _loading = false;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _menuSub?.cancel(); // 메모리 누수 방지
    super.dispose();
  }
}
