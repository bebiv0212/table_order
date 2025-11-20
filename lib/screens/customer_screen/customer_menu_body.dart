import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/screens/customer_screen/widget/menu_detail_card.dart';
import 'package:table_order/screens/customer_screen/widget/menu_item_card.dart';
import 'package:table_order/screens/customer_screen/widget/side_category_selector.dart';
import 'package:table_order/screens/customer_screen/widget/staff_call_dialog.dart';

import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/common_widgets/appbar_action_btn.dart';
import '../../widgets/common_widgets/custom_appbar.dart';
import '../../widgets/common_widgets/logout_button.dart';
import 'order_history_screen.dart';

//“전체 화면 + CartProvider / MenuProvider / CategoryProvider

class _CustomerMenuBody extends StatelessWidget {
  final String adminUid;
  final String shopName;
  final String tableNumber;

  const _CustomerMenuBody({
    required this.adminUid,
    required this.shopName,
    required this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    final menuProv = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();
    final category = context.watch<CategoryProvider>().selected;

    /// 🔥 메뉴 카테고리 자동 수집
    final categories = [
      "전체",
      ...{for (final m in menuProv.menus) m.category}
    ];

    /// 🔥 필터링 반영
    final filteredMenus = category == "전체"
        ? menuProv.menus
        : menuProv.menus.where((m) => m.category == category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        storeName: shopName,
        description: "테이블 $tableNumber",
        actionBtn1: AppbarActionBtn(
          icon: LucideIcons.receiptText,
          title: '주문내역',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderHistoryScreen(
                  adminUid: adminUid,
                  tableNumber: tableNumber,
                ),
              ),
            );
          },
        ),
        logoutBtn: const LogoutButton(),
      ),
      body: Row(
        children: [
          /// 🔥 카테고리 사이드바
          SideCategorySelector(
            categories: categories,
            onCallStaff: () {
              showDialog(
                context: context,
                builder: (_) => StaffCallDialog(onSelect: (_) {}),
              );
            },
          ),

          /// 🔥 메뉴 그리드
          Expanded(
            child: menuProv.loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMenus.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
                mainAxisExtent: 300,
              ),
              itemBuilder: (context, index) {
                final menu = filteredMenus[index];

                /// 🔥 장바구니에 이미 있는 수량 가져오기
                final count = cart.items
                    .firstWhere(
                      (e) => e['title'] == menu.name,
                  orElse: () => {'count': 0},
                )['count'] ??
                    0;

                return MenuItemCard(
                  title: menu.name,
                  subtitle: menu.description,
                  price: menu.price,
                  imageUrl: menu.imageUrl,
                  tagText: menu.category,
                  count: count,
                  isSoldOut: !menu.isAvailable,

                  /// 🔥 담기 (+)
                  onIncrease: menu.isAvailable
                      ? () => cart.addItem({
                    'title': menu.name,
                    'price': menu.price,
                    'imageUrl': menu.imageUrl,
                    'tag': menu.category,
                  })
                      : null,

                  /// 🔥 감소 (–)
                  onDecrease: menu.isAvailable
                      ? () => cart.decreaseItem({
                    'title': menu.name,
                  })
                      : null,

                  onTap: menu.isAvailable
                      ? () {
                    showDialog(
                      context: context,
                      builder: (_) => MenuDetailCard(
                        title: menu.name,
                        subtitle: menu.description,
                        price: menu.price,
                        imageUrl: menu.imageUrl,
                        tagText: menu.category,
                        initialCount: count == 0 ? 1 : count,

                        // 🔥 디테일에서 장바구니에 담을 때 로직
                        onAddToCart: (title, _, newCount) {
                          // 이미 장바구니에 있는지 확인
                          final existIndex = cart.items.indexWhere(
                                (e) => e['title'] == title,
                          );

                          if (existIndex == -1) {
                            // 아직 장바구니에 없는 메뉴면 먼저 1개 add
                            cart.addItem({
                              'title': menu.name,
                              'price': menu.price,
                              'imageUrl': menu.imageUrl,
                              'tag': menu.category,
                            });

                          }
                          // 그리고 setItemCount로 최종 수량 맞춰주기
                          cart.setItemCount(title, newCount);
                        },
                      ),
                    );
                  }
                      : null,

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
