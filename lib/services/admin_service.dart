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
        .update({"status": newStatus, "updatedAt": Timestamp.now()});
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

  // 호출 삭제
  Future<void> deleteStaffCall({
    required String adminUid,
    required String callId,
  }) async {
    await _db
        .collection('admins')
        .doc(adminUid)
        .collection('staffCalls')
        .doc(callId)
        .delete();
  }

  // 직원 호출 타입 → 한글 변환 맵
  Map<String, String> staffCallLabelMap = {
    "water": "물",
    "fork": "수저/포크",
    "tissue": "휴지/물티슈",
    "plate": "앞접시",
    "apron": "앞치마",
    "staff": "직원호출",
  };

  // 공용 함수로 가져갈 수도 있음
  String staffCallLabel(String code) {
    return staffCallLabelMap[code] ?? code;
  }
}
