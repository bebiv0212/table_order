import 'package:flutter/material.dart';
import 'package:table_order/enum/order_status.dart';
import 'package:table_order/theme/app_colors.dart';

class OrderList extends StatelessWidget {
  final String id;
  final String time;
  final String price;
  final String menu;
  final VoidCallback onProcess;
  final VoidCallback onPaid;
  final OrderStatus currentStatus;

  const OrderList({
    super.key,
    required this.id,
    required this.time,
    required this.price,
    required this.menu,
    required this.onProcess,
    required this.onPaid,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(fontSize: 13, color: Colors.black54)),
              Text(price, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),

          SizedBox(height: 4),

          /// 메뉴 텍스트
          Text(menu, style: TextStyle(fontSize: 13, color: Colors.black87)),

          SizedBox(height: 10),

          Row(
            children: [
              // 테이블별에서만 표시
              if (currentStatus == OrderStatus.table)
                // 주문처리 완료 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: onProcess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("주문처리 완료", style: TextStyle(fontSize: 12)),
                  ),
                ),

              SizedBox(width: 8),

              // 테이블별, 완료 에서만 결제완료 표시
              if (currentStatus == OrderStatus.table ||
                  currentStatus == OrderStatus.done)

                // 결제완료 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPaid,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.adminPrimary),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("결제완료", style: TextStyle(fontSize: 12, color: AppColors.adminPrimary)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
