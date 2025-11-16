import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/enum/order_status.dart';
import 'order_list.dart';

class OrderCard extends StatelessWidget {
  final String tableName;
  final String summary;
  final OrderStatus status;
  final VoidCallback onDelete;
  final List<OrderList> orderLists;

  const OrderCard({
    super.key,
    required this.tableName,
    required this.summary,
    required this.status,
    required this.onDelete,
    required this.orderLists,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단: 테이블명 + 삭제버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tableName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: Colors.redAccent,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          SizedBox(height: 2),

          // 주문 요약
          Text(
            summary,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 8),

          // 상태 배지
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: status.backgroundColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${status.label} ${orderLists.length}건",
              style: TextStyle(
                fontSize: 12,
                color: status.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: 10),

          // 주문 리스트
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 340,
            ),
            child: Scrollbar(
              radius: Radius.circular(10),
              thumbVisibility: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: orderLists.length,
                itemBuilder: (context, i) => orderLists[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
