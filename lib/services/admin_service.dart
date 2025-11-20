import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 오늘 날짜 ID
  String get todayId {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// 상태 업데이트
  Future<void> updateStatus({
    required String adminUid,
    required String orderId,
    required String newStatus,
  }) async {
    await _db
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(todayId)
        .collection('list')
        .doc(orderId)
        .update({
      "status": newStatus,
      "updatedAt": Timestamp.now(),
    });
  }

  /// 주문 삭제
  Future<void> deleteOrder({
    required String adminUid,
    required String orderId,
  }) async {
    await _db
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(todayId)
        .collection('list')
        .doc(orderId)
        .delete();
  }
}