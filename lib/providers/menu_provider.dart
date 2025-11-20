import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/models/menu_model.dart';

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  bool _loading = false;
  bool get loading => _loading;

  /// 메뉴 불러오기
  Future<void> loadMenus(String adminUid) async {
    _loading = true;
    notifyListeners();

    final query = await _db
        .collection('admins')
        .doc(adminUid)
        .collection('menus')
        .get();

    _menus = query.docs
        .map((doc) => MenuModel.fromMap(doc.data(), doc.id))
        .toList();

    _loading = false;
    notifyListeners();
  }
}
