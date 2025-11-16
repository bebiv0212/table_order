import 'package:flutter/material.dart';
import 'package:table_order/models/order_item.dart';
import 'package:uuid/uuid.dart';
import '../enum/order_status.dart';

class OrderProvider with ChangeNotifier {
  OrderStatus selectedStatus = OrderStatus.table;
  List<OrderItem> orders = [];

  // 더미 데이터용 Map (UI 표시용)
  final Map<String, List<String>> _ordersByStatus = {
    "테이블별": [],
    "진행중": [],
    "완료": [],
    "결제완료": [],
  };

  // UI 새로고침
  void _refresh() => notifyListeners();

  // 상태 변경
  void setStatus(OrderStatus status) {
    if (selectedStatus == status) return;
    selectedStatus = status;
    _refresh();
  }

  // 주문 추가
  void addOrder(String tableName, String menuSummary, OrderStatus status) {
    orders.add(OrderItem(
      id: const Uuid().v4(),
      tableName: tableName,
      menuSummary: menuSummary,
      status: status,
      time: DateTime.now(),
    ));

    // 상태별 텍스트 리스트에도 반영
    final tabLabel = _statusToLabel(status);
    _ordersByStatus[tabLabel]?.add("$tableName · $menuSummary");

    _refresh();
  }

  // 주문 삭제
  void deleteOrder(String id) {
    final item = orders.firstWhere((e) => e.id == id);
    final tabLabel = _statusToLabel(item.status);
    _ordersByStatus[tabLabel]?.removeWhere(
          (text) => text.contains(item.tableName),
    );
    orders.removeWhere((e) => e.id == id);
    _refresh();
  }

  // 상태별 필터링 (기존 로직 그대로)
  List<OrderItem> get filteredOrders =>
      orders.where((e) => e.status == selectedStatus).toList();

  // 상태 텍스트로 접근하는 더미용 getter
  Map<String, List<String>> get ordersByStatus => _ordersByStatus;

  // 현재 탭의 문자열 주문 목록 (UI용)
  List<String> get currentOrders {
    final label = _statusToLabel(selectedStatus);
    return List.unmodifiable(_ordersByStatus[label] ?? []);
  }

  String get emptyText => "${_statusToLabel(selectedStatus)} 주문이 없습니다";

  // 상태 -> 텍스트 변환 유틸
  String _statusToLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.table:
        return "테이블별";
      case OrderStatus.progress:
        return "진행중";
      case OrderStatus.done:
        return "완료";
      case OrderStatus.paid:
        return "결제완료";
    }
  }

  // 카드 카운트용
  int get totalCount => orders.length;
  int get progressCount =>
      orders.where((e) => e.status == OrderStatus.progress).length;
  int get doneCount =>
      orders.where((e) => e.status == OrderStatus.done).length;
  int get paidCount =>
      orders.where((e) => e.status == OrderStatus.paid).length;
}
