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
    final orderRef = _firestore
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(); // 자동 ID 생성

    final orderData = {
      "orderId": orderRef.id,
      "tableNumber": tableNumber,
      "status": "pending", // 주문 접수됨
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
