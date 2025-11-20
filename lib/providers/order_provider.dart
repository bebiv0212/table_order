import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../enum/order_status.dart';

class OrderProvider with ChangeNotifier {
  OrderStatus selectedStatus = OrderStatus.pending;

  // Firestore에서 가져오는 식당 이름
  String shopName = "";
  String adminUid = "";

  //List<OrderItem> orders = [];

  // // 더미 데이터용 Map (UI 표시용)
  // final Map<String, List<String>> _ordersByStatus = {
  //   "진행중": [],
  //   "결제대기": [],
  //   "결제완료": [],
  // };

  /// ---------------------------
  /// 식당 이름 Firestore에서 로드
  /// ---------------------------
  Future<void> loadShopName(String adminUid) async {
    this.adminUid = adminUid;

    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(adminUid)
        .get();

    if (doc.exists) {
      shopName = doc.data()?['shopName'] ?? "";
      notifyListeners();
    }
  }

  // UI 새로고침
  void _refresh() => notifyListeners();

  // 상태 변경
  void setStatus(OrderStatus status) {
    if (selectedStatus == status) return;
    selectedStatus = status;
    _refresh();
  }

  // 주문 추가 (더미용)
  // void addOrder(String tableName, String menuSummary, OrderStatus status) {
  //   orders.add(
  //     OrderItem(
  //       id: Uuid().v4(),
  //       tableName: tableName,
  //       menuSummary: menuSummary,
  //       status: status,
  //       time: DateTime.now(),
  //     ),
  //   );

  //   // 상태별 텍스트 리스트에도 반영
  //   final tabLabel = _statusToLabel(status);
  //   _ordersByStatus[tabLabel]?.add("$tableName · $menuSummary");

  //   _refresh();
  // }

  // 주문 삭제
  // void deleteOrder(String id) {
  //   final item = orders.firstWhere((e) => e.id == id);
  //   final tabLabel = _statusToLabel(item.status);
  //   _ordersByStatus[tabLabel]?.removeWhere(
  //     (text) => text.contains(item.tableName),
  //   );
  //   orders.removeWhere((e) => e.id == id);
  //   _refresh();
  // }

  // // 상태별 필터링
  // List<OrderItem> get filteredOrders =>
  //     orders.where((e) => e.status == selectedStatus).toList();

  // // 상태 문자열 기반 더미 getter
  // Map<String, List<String>> get ordersByStatus => _ordersByStatus;

  // 현재 탭 문자열
  // List<String> get currentOrders {
  //   final label = _statusToLabel(selectedStatus);
  //   return List.unmodifiable(_ordersByStatus[label] ?? []);
  // }

  // String get emptyText => "${_statusToLabel(selectedStatus)} 주문이 없습니다";

  // // 상태 → 텍스트
  // String _statusToLabel(OrderStatus s) {
  //   switch (s) {
  //     case OrderStatus.pending:
  //       return "테이블별";
  //     case OrderStatus.done:
  //       return "완료";
  //     case OrderStatus.paid:
  //       return "결제완료";
  //   }
  // }
}
