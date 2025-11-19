import 'package:flutter/material.dart';
import 'package:table_order/models/menu_model.dart';
import 'package:table_order/services/menu_service.dart';

/// 🔹 관리자 한 가게의 "메뉴 목록"을 관리하는 Provider
/// - Firestore에서 메뉴 불러오기
/// - 메뉴 삭제
/// - 로딩 상태 관리
class MenuListProvider extends ChangeNotifier {
  /// 실제 파이어스토어/스토리지를 건드리는 서비스 레이어
  final MenuService _service = MenuService();

  /// 현재 화면에 보여줄 메뉴 목록
  List<MenuModel> menus = [];

  /// 메뉴를 불러오는 중인지 여부 (로딩 스피너 표시용)
  bool loading = true;

  /// ✅ 특정 관리자(adminUid)의 메뉴 리스트 불러오기
  Future<void> loadMenus(String adminUid) async {
    loading = true; // 1) 로딩 시작 → UI에서 로딩 스피너 보여줄 수 있게
    notifyListeners(); //    화면에 "로딩 중" 반영

    // 2) Firestore에서 메뉴 목록 가져오기
    menus = await _service.getMenus(adminUid);

    // 3) 로딩 끝
    loading = false;
    notifyListeners(); // 화면에 실제 메뉴 리스트 반영
  }

  /// ✅ 메뉴 삭제 (Firestore 문서 + Storage 이미지 같이 삭제)
  Future<void> deleteMenu(String adminUid, MenuModel menu) async {
    try {
      /// 1) 서비스에 삭제 요청
      ///    - Firestore: admins/{adminUid}/menus/{menu.id} 삭제
      ///    - Storage: menu.imageUrl 경로의 사진 삭제
      await _service.deleteMenu(adminUid, menu.id!, menu.imageUrl);

      // 2) 로컬 상태에서도 삭제 (UI 즉시 반영)
      menus.removeWhere((m) => m.id == menu.id);

      // 3) 변경 사항 알리기 → Consumer 위젯들이 다시 build됨
      notifyListeners();
    } catch (e) {
      // 삭제 실패 시 콘솔 로그
      debugPrint("삭제 오류: $e");
    }
  }

  Future<void> toggleAvailability(
    String adminUid,
    MenuModel menu,
    bool newValue,
  ) async {
    try {
      // 1️⃣ Firestore에서 판매 여부 업데이트
      await _service.updateAvailability(adminUid, menu.id!, newValue);

      // 2️⃣ 로컬 리스트 업데이트 (즉시 반영)
      final index = menus.indexWhere((m) => m.id == menu.id);
      if (index != -1) {
        menus[index] = menus[index].copyWith(isAvailable: newValue);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("판매 상태 변경 오류: $e");
    }
  }
}
