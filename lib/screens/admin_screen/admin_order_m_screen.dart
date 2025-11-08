import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';

class AdminOrderMScreen extends StatelessWidget {
  final String shopName;
  const AdminOrderMScreen({super.key, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: CustomAppBar(
        storeName: '$shopName 관리',
        description: '실시간 주문 현황',
        actionBtn1: AppbarActionBtn(
          icon: LucideIcons.receiptText,
          title: '메뉴관리',
        ),
        actionBtn2: AppbarActionBtn(
          icon: LucideIcons.messageSquare,
          title: '리뷰관리',
        ),
      ),
      body: SafeArea(child: Center(child: Text('주문 데이터 불러오는 중...'))),
    );
  }
}
