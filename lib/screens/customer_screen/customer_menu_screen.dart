import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';

class CustomerMenuScreen extends StatelessWidget {
  const CustomerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: CustomAppBar(
        storeName: '맛있는 식당', //
        description: '01',
        actionBtn1: AppbarActionBtn(
          icon: LucideIcons.receiptText,
          title: '주문내역',
        ),
      ),
      body: SafeArea(child: Column(children: [])),
    );
  }
}
