import 'package:cloud_firestore/cloud_firestore.dart';

class StaffCallService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> callStaff({
    required String adminUid,
    required String tableNumber,
    required String callType, // 물, 앞접시, 직원호출 등
  }) async {
    final ref = _db
        .collection("admins")
        .doc(adminUid)
        .collection("staffCalls")
        .doc(); // callId 자동 생성

    await ref.set({
      "callId": ref.id,
      "tableNumber": tableNumber,
      "callType": callType,
      "status": "pending",         // pending = 처리 전
      "createdAt": Timestamp.now(),
    });
  }
}
