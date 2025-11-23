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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tableName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              // 결제완료 탭에선 표시x
              if (status != OrderStatus.paid)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),

          SizedBox(height: 4),

          Text(
            summary,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),

          SizedBox(height: 10),

          /// 주문 리스트
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 340),
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(), // 스크롤 부드러운 효과
              itemCount: orderLists.length,
              itemBuilder: (context, i) => orderLists[i],
            ),
          ),
        ],
      ),
    );
  }
}
