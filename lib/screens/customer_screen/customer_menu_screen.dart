import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/screens/customer_screen/order_history_screen.dart';
import 'package:table_order/screens/customer_screen/widget/cart_side_sheet.dart';
import 'package:table_order/screens/customer_screen/widget/staff_call_dialog.dart';
import 'package:table_order/services/order_service.dart';
import 'package:table_order/utlis/format_utils.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';
import 'package:table_order/screens/customer_screen/widget/menu_detail_card.dart';
import 'package:table_order/screens/customer_screen/widget/menu_item_card.dart';
import 'package:table_order/screens/customer_screen/widget/side_category_selector.dart';
import 'package:table_order/providers/category_provider.dart';
import 'package:table_order/providers/cart_provider.dart';
import 'package:table_order/providers/menu_provider.dart'; // 🔥 추가됨
import 'package:table_order/widgets/common_widgets/logout_button.dart';

class CustomerMenuScreen extends StatelessWidget {
  final String adminUid;
  final String shopName;
  final String tableNumber;

  const CustomerMenuScreen({
    super.key,
    required this.shopName,
    required this.tableNumber,
    required this.adminUid,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      /// 🔥 화면 들어오면 Firebase에서 메뉴 로딩
      create: (_) {
        final provider = MenuProvider();
        provider.loadMenus(adminUid);
        return provider;
      },

      /// 🔥 Provider 생성 후 본문 위젯 빌드
      child: _CustomerMenuBody(
        adminUid: adminUid,
        shopName: shopName,
        tableNumber: tableNumber,
      ),
    );
  }
}

/// ----------------------------------------------------------------------
/// 🔥 실제 화면 UI는 별도 위젯으로 분리 (Provider rebuild 충돌 방지)
/// ----------------------------------------------------------------------
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
    final menuProv = context.watch<MenuProvider>(); // 🔥 Firebase 메뉴 목록
    final category = context.watch<CategoryProvider>().selected;
    final cart = context.watch<CartProvider>();
    final orderService = OrderService();

    // 🔥 카테고리 자동 생성 (중복 제거 + '전체' 추가)
    final categories = [
      '전체',
      ...{for (final m in menuProv.menus) m.category},
    ];

    // 🔥 선택된 카테고리로 필터링
    final filteredMenus = category == '전체'
        ? menuProv.menus
        : menuProv.menus.where((m) => m.category == category).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),

      /// 상단 AppBar
      appBar: CustomAppBar(
        storeName: shopName,
        description: '테이블 $tableNumber',
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
        logoutBtn: LogoutButton(requirePassword: true),
      ),

      body: Stack(
        children: [
          Row(
            children: [
              /// 🔥 카테고리 선택 패널
              SideCategorySelector(
                categories: categories,
                // selectedCategory: category,
                // onCategorySelected: (cat) =>
                //   context.read<CategoryProvider>().select(cat),
                onCallStaff: () {
                  showDialog(
                    context: context,
                    builder: (_) => StaffCallDialog(
                      onSelect: (type) {
                        debugPrint("직원 호출: $type");
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),

              /// 메뉴 그리드 영역
              Expanded(
                child: menuProv.loading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredMenus.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                          mainAxisExtent: 300,
                        ),
                        itemBuilder: (context, index) {
                          final menu = filteredMenus[index];

                          // 🔥 현재 장바구니에 몇 개 담겨있나?
                          final current =
                              cart.items.firstWhere(
                                    (e) => e['title'] == menu.name,
                                    orElse: () => {'count': 0},
                                  )['count']
                                  as int;

                          return MenuItemCard(
                            title: menu.name,
                            subtitle: menu.description,
                            price: menu.price,
                            imageUrl: menu.imageUrl,
                            tagText: menu.category,
                            count: current,

                            /// 🔥 품절 처리 적용
                            isSoldOut: !menu.isAvailable,

                            /// 🔥 수량 증가
                            onIncrease: () {
                              if (!menu.isAvailable) return;
                              cart.addItem({
                                'menuId': menu.id,
                                'title': menu.name,
                                'price': menu.price,
                                'imageUrl': menu.imageUrl,
                                'tag': menu.category,
                              });
                            },

                            /// 🔥 수량 감소
                            onDecrease: () {
                              if (!menu.isAvailable) return;
                              cart.decreaseItem({'title': menu.name});
                            },

                            /// 🔥 상품 상세 보기
                            onTap: menu.isAvailable
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => MenuDetailCard(
                                        adminUid: adminUid,
                                        menuId: menu.id,
                                        title: menu.name,
                                        subtitle: menu.description,
                                        price: menu.price,
                                        imageUrl: menu.imageUrl,
                                        tagText: menu.category,
                                        initialCount: current == 0
                                            ? 1
                                            : current,

                                        onAddToCart: (title, price, newCount) {
                                          final existIndex = cart.items
                                              .indexWhere(
                                                (e) => e['title'] == title,
                                              );

                                          if (existIndex == -1) {
                                            cart.addItem({
                                              'menuId': menu.id,
                                              'title': menu.name,
                                              'price': menu.price,
                                              'imageUrl': menu.imageUrl,
                                              'tag': menu.category,
                                            });
                                          }

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

          /// 하단 장바구니 패널
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,

            left: 0,
            right: 0,
            bottom: cart.items.isEmpty ? -100 : 0,

            child: Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),

              /// 장바구니 수량 + 버튼
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 ${cart.totalCount}개\n${formatWon(cart.totalPrice)}원',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        transitionDuration: Duration(milliseconds: 300),
                        pageBuilder: (_, __, ___) => CartSideSheet(
                          onOrder: () async {
                            if (cart.items.isEmpty) return;

                            await orderService.submitOrder(
                              adminUid: adminUid,
                              tableNumber: tableNumber,
                              cartItems: cart.items,
                              totalPrice: cart.totalPrice,
                            );

                            if (!context.mounted) return;

                            // 2) 장바구니 내용 초기화
                            cart.clear();
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("주문이 접수되었습니다!")),
                            );
                          },
                        ),
                        transitionBuilder: (_, anim, __, child) {
                          final offset =
                              Tween(
                                begin: Offset(1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOutCubic,
                                ),
                              );
                          return SlideTransition(
                            position: offset,
                            child: child,
                          );
                        },
                      );
                    },
                    icon: Icon(LucideIcons.shoppingCart, color: Colors.white),
                    label: Text('장바구니 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE8751A),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
