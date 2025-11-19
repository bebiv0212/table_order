import 'package:flutter/material.dart';
import 'package:table_order/models/menu_model.dart';
import 'package:table_order/services/menu_service.dart';

class MenuListProvider extends ChangeNotifier {
  final MenuService _service = MenuService();

  List<MenuModel> menus = [];
  bool loading = true;

  Future<void> loadMenus(String adminUid) async {
    loading = true;
    notifyListeners();

    menus = await _service.getMenus(adminUid);
    loading = false;
    notifyListeners();
  }

  Future<void> deleteMenu(String adminUid, String menuId) async {
    await _service.deleteMenu(adminUid, menuId);
    await loadMenus(adminUid);
  }
}
