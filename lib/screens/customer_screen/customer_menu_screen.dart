import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/screens/customer_screen/widget/cart_side_sheet.dart';
import 'package:table_order/utlis/format_utils.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';
import 'package:table_order/screens/customer_screen/widget/menu_detail_card.dart';
import 'package:table_order/screens/customer_screen/widget/menu_item_card.dart';
import 'package:table_order/screens/customer_screen/widget/side_category_selector.dart';
import 'package:table_order/providers/category_provider.dart';
import 'package:table_order/providers/cart_provider.dart';

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
    final category = context.watch<CategoryProvider>().selected;
    final cart = context.watch<CartProvider>();

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': '아메리카노',
        'subtitle': '진한 에스프레소에 뜨거운 물을 더한 기본 커피',
        'price': 4500,
        'tag': '음료',
        'imageUrl':
            'https://images.unsplash.com/photo-1509043759401-136742328bb3?q=80&w=1600',
      },
      {
        'title': '카페라떼',
        'subtitle': '부드러운 우유와 에스프레소의 조화',
        'price': 5000,
        'tag': '음료',
        'imageUrl':
            'https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=1600',
      },
      {
        'title': '리코타 샐러드',
        'subtitle': '리코타 치즈와 신선한 채소의 조화',
        'price': 8500,
        'tag': '메인',
        'imageUrl':
            'https://images.unsplash.com/photo-1601050690597-3b4c1cfbff1d?q=80&w=1600',
      },
      {
        'title': '티라미수 케이크',
        'subtitle': '부드럽고 달콤한 치즈케이크',
        'price': 6000,
        'tag': '디저트',
        'imageUrl':
            'https://images.unsplash.com/photo-1627308595187-94aef2707ba0?q=80&w=1600',
      },
    ];

    final List<String> categories = ['전체', '메인', '음료', '디저트'];

    final filteredItems = category == '전체'
        ? menuItems
        : menuItems.where((m) => m['tag'] == category).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        storeName: shopName,
        description: '테이블 $tableNumber',
        actionBtn1: AppbarActionBtn(
          icon: LucideIcons.receiptText,
          title: '주문내역',
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              SideCategorySelector(
                categories: categories,
                selectedCategory: category,
                onCategorySelected: (cat) =>
                    context.read<CategoryProvider>().select(cat),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    mainAxisExtent: 300,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final current =
                        cart.items.firstWhere(
                              (e) => e['title'] == item['title'],
                              orElse: () => {'count': 0},
                            )['count']
                            as int;

                    return MenuItemCard(
                      title: item['title'],
                      subtitle: item['subtitle'],
                      price: item['price'],
                      imageUrl: item['imageUrl'],
                      tagText: item['tag'],
                      count: current,
                      onIncrease: () => cart.addItem(item),
                      onDecrease: () => cart.decreaseItem(item['title']),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => MenuDetailDialog(
                            title: item['title'],
                            subtitle: item['subtitle'],
                            price: item['price'],
                            imageUrl: item['imageUrl'],
                            tagText: item['tag'],
                            initialCount: current == 0 ? 1 : current,
                            onAddToCart: (title, price, count) {
                              cart.setItemCount(title, count);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, __, ___) => CartSideSheet(
                          cartItems: cart.items,
                          totalPrice: cart.totalPrice,
                          onIncrease: (title) => cart.addItem(
                            cart.items.firstWhere((e) => e['title'] == title),
                          ),
                          onDecrease: cart.decreaseItem,
                          onRemove: cart.removeItem,
                        ),
                        transitionBuilder: (_, anim, __, child) {
                          final offset =
                              Tween(
                                begin: const Offset(1, 0),
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
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
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
