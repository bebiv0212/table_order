import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/menu_form_provider.dart';
import 'package:table_order/providers/menu_list_provider.dart';
import 'package:table_order/screens/admin_screen/widget/menu_form_page.dart';
import 'package:table_order/screens/admin_screen/widget/menu_card.dart';
import 'package:table_order/theme/app_colors.dart';

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
            backgroundColor: const Color(0xFFF8F8F8),

            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0.5,
              toolbarHeight: 80,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '메뉴 관리',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '총 ${menus.length}개 메뉴',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton.icon(
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

                      prov.loadMenus(adminUid); // 돌아오면 새로고침
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.adminPrimary,
                    ),
                    icon: const Icon(
                      LucideIcons.plus,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "메뉴 추가",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            body: prov.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: categories.map((category) {
                        final list = menus.where((m) => m.category == category);

                        return Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // ← 가로 3칸
                                    mainAxisSpacing: 18,
                                    crossAxisSpacing: 18,
                                    childAspectRatio: 1.89,
                                  ),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final menu = list.elementAt(index);

                                return MenuCard(
                                  menu: menu,
                                  onDelete: () async {
                                    await prov.deleteMenu(adminUid, menu.id!);
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
