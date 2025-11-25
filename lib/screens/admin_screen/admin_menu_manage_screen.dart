import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/menu_form_provider.dart';
import 'package:table_order/providers/menu_list_provider.dart';
import 'package:table_order/screens/admin_screen/widget/admin_page_appbar.dart';
import 'package:table_order/screens/admin_screen/widget/menu_card.dart';
import 'package:table_order/screens/admin_screen/widget/menu_form_page.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/empty_screen.dart';

class AdminMenuManageScreen extends StatelessWidget {
  final String adminUid;

  const AdminMenuManageScreen({super.key, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuListProvider()..loadMenus(adminUid),
      child: Consumer<MenuListProvider>(
        builder: (context, prov, _) {
          final menus = prov.menus;

          final categories = menus
              .map((e) => e.category.isEmpty ? "기타" : e.category)
              .toSet()
              .toList();

          return Scaffold(
            backgroundColor: Color(0xFFF8F8F8),

            appBar: AdminPageAppBar(
              title: '메뉴 관리',
              subtitle: '총 ${menus.length}개 메뉴',
              primaryActionLabel: '메뉴 추가',
              primaryActionIcon: LucideIcons.plus,
              onPrimaryAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => MenuFormProvider(),
                      child: MenuFormPage(adminUid: adminUid),
                    ),
                  ),
                );
                prov.loadMenus(adminUid);
              },
            ),

            body: prov.loading
                ? Center(child: CircularProgressIndicator())
                : menus.isEmpty
                ? EmptyScreen(
                    message: '등록된 메뉴가 없습니다',
                    buttonText: '메뉴 추가하기',
                    buttonColor: AppColors.adminPrimary,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => MenuFormProvider(),
                            child: MenuFormPage(adminUid: adminUid),
                          ),
                        ),
                      );
                      prov.loadMenus(adminUid);
                    },
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: categories.map((category) {
                        final list = menus.where((m) => m.category == category);

                        return Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // ← 가로 3칸
                                    mainAxisSpacing: 18,
                                    crossAxisSpacing: 18,
                                    childAspectRatio: 1.7,
                                  ),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final menu = list.elementAt(index);

                                return MenuCard(
                                  adminUid: adminUid,
                                  menu: menu,
                                  onDelete: () async {
                                    await prov.deleteMenu(adminUid, menu);
                                  },
                                  onEdit: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                          create: (_) => MenuFormProvider(),
                                          child: MenuFormPage(
                                            adminUid: adminUid,
                                            isEdit: true,
                                            menu: menu, // ← 기존 메뉴 전달
                                          ),
                                        ),
                                      ),
                                    );
                                    prov.loadMenus(adminUid);
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
