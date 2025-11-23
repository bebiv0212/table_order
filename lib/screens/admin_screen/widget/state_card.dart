import 'package:flutter/material.dart';

class AdminStateCard extends StatelessWidget {
  final String title;
  final String orderCount;
  final Icon? icon;
  final Color? backgroundColor;
  final Color? borderColor;

  const AdminStateCard({
    super.key,
    required this.title,
    required this.orderCount,
    this.icon, this.backgroundColor, this.borderColor,
  });



  @override
  Widget build(BuildContext context) {
    // 상태 카드 위젯
    return Container(
      width: 300,
      height: 130,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
        ),
      ),

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(title, style: TextStyle(fontSize: 30, color: Colors.grey)),
            Row(
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: 6),
                ],
                Text(orderCount, style: TextStyle(fontSize: 30)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
