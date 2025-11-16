import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/utlis/format_utils.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String adminUid;
  final String tableNumber;

  const OrderHistoryScreen({
    super.key,
    required this.adminUid,
    required this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .where('tableNumber', isEqualTo: tableNumber)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          '주문 내역',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          // 로딩 중
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          // 주문 내역이 없으면 기본 화면
          if (orders.isEmpty) {
            return _buildEmptyView(context);
          }

          // 주문이 있을 때 → 리스트 전체 출력
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주문 내역',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // 모든 주문 렌더링
                ...orders.map((doc) {
                  final order = doc.data() as Map<String, dynamic>;
                  final items = order['items'] as List<dynamic>;
                  final createdAt = order['createdAt'] as Timestamp;

                  return _orderContainer(order, createdAt, items);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Container _orderContainer(
    Map<String, dynamic> order,
    Timestamp createdAt,
    List<dynamic> items,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주문 상태 + 총 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(order['status']),
              Text(
                '${formatWon(order['totalPrice'])}원',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 6),

          Text(
            formatTime(createdAt.toDate()),
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),

          SizedBox(height: 14),

          // 메뉴 리스트
          ...items.map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${formatWon(item['price'])}원 × ${item['quantity']}',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatWon(item['price']),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 주문 상태 배지
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFFFEFC2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.clock4, size: 16, color: Colors.orange),
          SizedBox(width: 4),
          Text("주문 접수", style: TextStyle(fontSize: 13, color: Colors.orange)),
        ],
      ),
    );
  }

  // 주문 없을 때 화면
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFEFEFF2),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.clock4, size: 40, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Text(
            '주문 내역이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '메뉴를 주문해보세요',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE8751A),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              '메뉴 보기',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
