import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/customer_screen/widget/review_write_dialog.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';
import 'package:table_order/widgets/common_widgets/empty_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String adminUid;
  final String tableNumber;

  const OrderHistoryScreen({
    super.key,
    required this.adminUid,
    required this.tableNumber,
  });

  /// 오늘 날짜 문자열 생성: yyyy-MM-dd
  String _todayDocId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final todayId = _todayDocId();

    /// 오늘 날짜 문서의 list 컬렉션만 읽기
    final ordersRef = FirebaseFirestore.instance
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(todayId)
        .collection('list')
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
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data!.docs;

          /// 1) 결제(Paid)된 주문은 아예 숨기기 (Firestore X, 클라이언트에서만 제거)
          final visibleOrders = allOrders.where((doc) {
            final o = doc.data() as Map<String, dynamic>;
            return o['status'] != 'paid';
          }).toList();

          /// 2) 주문이 하나도 안 남으면 "주문 없음" 화면
          if (visibleOrders.isEmpty) {
            return EmptyScreen(
              message: '주문 내역이 없습니다',
              buttonText: '메뉴 보기',
              buttonColor: AppColors.customerPrimary,
              onPressed: () => Navigator.pop(context),
            );
          }

          /// 3) 진행중 / 완료 분리
          final ongoing = visibleOrders.where((doc) {
            final o = doc.data() as Map<String, dynamic>;
            return o['status'] != 'done';
          }).toList();

          final completed = visibleOrders.where((doc) {
            final o = doc.data() as Map<String, dynamic>;
            return o['status'] == 'done';
          }).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 진행중 주문
                if (ongoing.isNotEmpty) ...[
                  Text(
                    '진행중인 주문',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14),

                  ...ongoing.map((doc) {
                    return _orderBox(context, doc, isDone: false);
                  }),
                  SizedBox(height: 36),
                ],

                /// 완료된 주문
                if (completed.isNotEmpty) ...[
                  Text(
                    '완료된 주문',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14),

                  ...completed.map((doc) {
                    return _orderBox(context, doc, isDone: true);
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// 주문 카드 하나
  Widget _orderBox(
    BuildContext context,
    QueryDocumentSnapshot<Object?> doc, {
    required bool isDone,
  }) {
    final order = doc.data() as Map<String, dynamic>;
    final items = order['items'] as List<dynamic>;
    final time = formatTime(order['createdAt'].toDate());

    // Firestore 구조에서
    // admins/{adminUid}/orders/{dateId}/list/{orderId}
    final String orderId = order['orderId'] ?? doc.id;
    final String orderDateId = doc.reference.parent.parent!.id;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDone ? Colors.white : Color.fromARGB(255, 255, 253, 234),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 상태 + 총가격
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusBadge(isDone),
              Text(
                '${formatWon(order['totalPrice'])}원',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 10),
          Text(time, style: TextStyle(color: Colors.black54, fontSize: 15)),
          SizedBox(height: 16),

          /// 메뉴 리스트
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                spacing: 10,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item['imageUrl'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${formatWon(item['price'])}원 × ${item['quantity']}',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    spacing: 5,
                    children: [
                      Text(
                        '${formatWon(item['price'] * item['quantity'])}원',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// 리뷰 버튼 (완료된 주문에서만)
                      if (isDone) ...[
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: _reviewBtn(
                            context,
                            item,
                            adminUid,
                            orderDateId,
                            orderId,
                            index,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 리뷰 버튼
  ElevatedButton _reviewBtn(
    BuildContext context,
    Map<String, dynamic> item,
    String adminUid,
    String orderDateId,
    String orderId,
    int itemIndex,
  ) {
    final reviewed = item['reviewed'] == true;

    return ElevatedButton(
      onPressed: reviewed
          ? null // 이미 리뷰 작성됨 → 비활성
          : () {
              showReviewWriteDialog(
                context: context,
                menuId: item['menuId'],
                menuName: item['name'],
                adminUid: adminUid,
                orderDateId: orderDateId,
                orderId: orderId,
                itemIndex: itemIndex,
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: reviewed ? Colors.grey[300] : Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: reviewed ? Colors.grey : Color(0xFF221004),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.messageSquare,
            color: reviewed ? Colors.grey[600] : Colors.black,
          ),
          SizedBox(width: 10),
          Text(
            reviewed ? '작성완료' : '리뷰쓰기',
            style: TextStyle(
              color: reviewed ? Colors.grey[600] : Colors.black,
              fontSize: 14,
              fontWeight: reviewed ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 상태 배지 (진행중 / 완료)
  Widget _statusBadge(bool isDone) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Color(0xFFD6F5D6) : Color(0xFFFFEFC2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? LucideIcons.badgeCheck : LucideIcons.clock4,
            size: 16,
            color: isDone ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 6),
          Text(
            isDone ? '완료' : '주문 접수',
            style: TextStyle(
              fontSize: 13,
              color: isDone ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
