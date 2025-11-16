import 'package:flutter/material.dart';

class AdminStateCard extends StatelessWidget {
  const AdminStateCard({
    super.key,
    required this.title,
    required this.orderCount,
  });

  final String title;
  final String orderCount;

  @override
  Widget build(BuildContext context) {
    // 상태 카드 위젯
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(title, style: TextStyle(fontSize: 30, color: Colors.grey)),
            Text(orderCount, style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
