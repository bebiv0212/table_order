import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../enum/order_status.dart';
import '../services/admin_service.dart';

class OrderProvider with ChangeNotifier {
  OrderStatus selectedStatus = OrderStatus.pending;

  // Firestore에서 가져오는 식당 이름
  String shopName = "";
  String adminUid = "";

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

  final adminService = AdminService();

  Future<void> markAsDone(String orderId) async {
    await adminService.updateStatus(
      adminUid: adminUid,
      orderId: orderId,
      newStatus: "done",
    );
  }

  Future<void> markAsPaid(String orderId) async {
    await adminService.updateStatus(
      adminUid: adminUid,
      orderId: orderId,
      newStatus: "paid",
    );
  }

  Future<void> removeOrder(String orderId) async {
    await adminService.deleteOrder(
      adminUid: adminUid,
      orderId: orderId,
    );
  }

  /// 오늘 날짜 ID
  String get todayId {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
