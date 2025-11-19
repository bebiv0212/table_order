import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitOrder({
    required String adminUid,
    required String tableNumber,
    required List<Map<String, dynamic>> cartItems,
    required int totalPrice,
  }) async {
    final today = DateTime.now();
    final dateId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final dateCollection = _firestore
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(dateId)
        .collection('list');

    final orderRef = dateCollection.doc(); // 날짜 아래에서 새 order 생성

    final orderData = {
      "orderId": orderRef.id,
      "adminUid": adminUid,
      "tableNumber": tableNumber,
      "status": "pending",
      "totalPrice": totalPrice,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
      "items": cartItems.map((item) {
        return {
          "name": item["title"],
          "price": item["price"],
          "quantity": item["count"],
          "imageUrl": item["imageUrl"],
        };
      }).toList(),
    };

    await orderRef.set(orderData);
  }
}
