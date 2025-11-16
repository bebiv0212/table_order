import 'package:flutter/material.dart';

class OrderList extends StatelessWidget {
  final String time; // 주문 시간
  final String price; // 금액
  final String menu; // 메뉴 요약
  final VoidCallback onProcess; // 주문처리 완료
  final VoidCallback onPaid; // 결제완료

  OrderList({
    super.key,
    required this.time,
    required this.price,
    required this.menu,
    required this.onProcess,
    required this.onPaid,
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
          // 상단: 시간 + 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          // 메뉴 요약
          Text(
            menu,
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),

          SizedBox(height: 10),

          // 주문처리, 결제완료 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onProcess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "주문처리 완료",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onPaid,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: Text(
                    "결제완료",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
