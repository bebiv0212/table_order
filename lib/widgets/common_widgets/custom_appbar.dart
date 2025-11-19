import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.storeName,
    required this.description,
    this.onOrderPressed,
    required this.actionBtn1,
    this.actionBtn2,
    this.logoutBtn,
  });

  final String storeName;
  final String description;
  final Widget actionBtn1;
  final Widget? actionBtn2;
  final Widget? logoutBtn;
  final VoidCallback? onOrderPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좌측 식당명 + 테이블 번호
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [actionBtn1, SizedBox(width: 10), ?actionBtn2, ?logoutBtn],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}
