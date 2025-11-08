import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';

class CustomerMenuScreen extends StatelessWidget {
  final String shopName; // ✅ 추가: 매장명
  final String tableNumber; // ✅ 추가: 테이블 번호

  const CustomerMenuScreen({
    super.key,
    required this.shopName,
    required this.tableNumber,
    required String adminUid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: CustomAppBar(
        storeName: shopName, // ✅ 로그인에서 전달받은 매장명
        description: '테이블 $tableNumber', // ✅ 로그인에서 전달받은 테이블 번호
        actionBtn1: AppbarActionBtn(
          icon: LucideIcons.receiptText,
          title: '주문내역',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            '$shopName ·  $tableNumber',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
