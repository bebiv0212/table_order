import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/menu_form_provider.dart';
import 'package:table_order/screens/admin_screen/widget/menu_form_page.dart';
import 'package:table_order/theme/app_colors.dart';

class AdminMenuManageScreen extends StatelessWidget {
  final String shopName;
  final int menuCount;
  final VoidCallback? onAddMenu;

  const AdminMenuManageScreen({
    super.key,
    required this.shopName,
    this.menuCount = 0,
    this.onAddMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메뉴 관리',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '총 $menuCount개 메뉴',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => MenuFormProvider(),
                      child: const MenuFormPage(),
                    ),
                  ),
                );

                if (result != null) {
                  debugPrint("메뉴 등록 완료: ${result.name}");
                  // TODO: Firebase 저장
                }
              },

              style: TextButton.styleFrom(
                backgroundColor: AppColors.adminPrimary, // 파란 버튼
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(LucideIcons.plus, size: 18, color: Colors.white),
              label: Text(
                '메뉴 추가',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),

      // 내용은 나중에 채우면 됨
      body: Center(
        child: Text('메뉴 관리 내용 영역', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
