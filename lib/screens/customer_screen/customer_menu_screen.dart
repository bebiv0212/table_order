import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/customer_screen/widget/cart_side_sheet.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';
import 'package:table_order/screens/customer_screen/widget/menu_detail_card.dart';
import 'package:table_order/screens/customer_screen/widget/menu_item_card.dart';
import 'package:table_order/screens/customer_screen/widget/side_category_selector.dart';


//class CustomerMenuScreen extends StatelessWidget {
//  final String shopName; // ✅ 추가: 매장명
//  final String tableNumber; // ✅ 추가: 테이블 번호

//  const CustomerMenuScreen({
//    super.key,
//    required this.shopName,
//    required this.tableNumber,
//    required String adminUid,
//  });

/// 고객용 주문 화면의 메인 페이지.
///
///
/// 설계 목적:
///  1. 데이터 흐름: 메뉴 → 카드 → 장바구니(공유 상태)
///  2. 시각적 계층: 카테고리(왼쪽) → 상품 리스트(오른쪽)
///  3. 상호작용 흐름: 담기 → 하단 바 → 오른쪽 팝업.
///
/// 상태는 State 내부에서 관리하지만, 이후 Provider로 분리 가능하도록 설계.
class CustomerMenuScreen extends StatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  // 현재 선택된 카테고리 (기본: 전체)
  String selectedCategory = '전체';

  // 더미 메뉴 데이터
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': '아메리카노',
      'subtitle': '진한 에스프레소에 뜨거운 물을 더한 기본 커피',
      'price': 4500,
      'tag': '음료',
      'imageUrl': 'https://images.unsplash.com/photo-1509043759401-136742328bb3?q=80&w=1600',
    },
    {
      'title': '카페라떼',
      'subtitle': '부드러운 우유와 에스프레소의 조화',
      'price': 5000,
      'tag': '음료',
      'imageUrl': 'https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=1600',
    },
    {
      'title': '리코타 샐러드',
      'subtitle': '리코타 치즈와 신선한 채소의 조화',
      'price': 8500,
      'tag': '메인',
      'imageUrl': 'https://images.unsplash.com/photo-1601050690597-3b4c1cfbff1d?q=80&w=1600',
    },
    {
      'title': '티라미수 케이크',
      'subtitle': '부드럽고 달콤한 치즈케이크',
      'price': 6000,
      'tag': '디저트',
      'imageUrl': 'https://images.unsplash.com/photo-1627308595187-94aef2707ba0?q=80&w=1600',
    },
  ];

  // 카테고리 목록 (추후 관리자 페이지에서 수정 가능)
  final List<String> categories = ['전체', '메인', '음료', '디저트'];

  // 장바구니 상태 (메모리 내 리스트)
  final List<Map<String, dynamic>> cart = [];

  // 총 수량 /금액
  int get totalCount => cart.fold(0, (sum, item) => sum + (item['count'] as int));
  int get totalPrice =>
      cart.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['count'] as int)));

  // 메뉴 추가 / 수량 변경
  void addToCart(String title, int price, int count, String imageUrl) {
    setState(() {
      final index = cart.indexWhere((e) => e['title'] == title);
      if (index == -1) {
        cart.add({'title': title, 'price': price, 'count': count, 'imageUrl': imageUrl});
      } else {
        cart[index]['count'] = count;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 카테고리 필터 적용 (선택된 태그에 해당하는 메뉴만 표시)
    final filteredItems = selectedCategory == '전체'
        ? menuItems
        : menuItems.where((m) => m['tag'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // 상단 앱 바
      appBar: CustomAppBar(
        storeName: shopName, // ✅ 로그인에서 전달받은 매장명
        description: '테이블 $tableNumber', // ✅ 로그인에서 전달받은 테이블 번호
        actionBtn1: AppbarActionBtn(
          icon: LucideIcons.receiptText,
          title: '주문내역',
        ),
      ),

      // Body 구조: Row (왼쪽 카테고리 + 오른쪽 메뉴그리드)
      body: Stack(
        children: [
          Row(
            children: [
              // 왼쪽 카테고리 선택 영역
              SideCategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                onCategorySelected: (cat) => setState(() => selectedCategory = cat),
              ),

              // 오른쪽 메뉴 리스트 (Grid 4열)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,     // 4열
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    mainAxisExtent: 300,   // 카드 높이 고정
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    // 장바구니에서 현재 아이템의 수량을 찾아 표시
                    final cartIndex = cart.indexWhere((e) => e['title'] == item['title']);
                    final currentCount = cartIndex == -1 ? 0 : cart[cartIndex]['count'] as int;

                    return MenuItemCard(
                      title: item['title'],
                      subtitle: item['subtitle'],
                      price: item['price'],
                      imageUrl: item['imageUrl'],
                      tagText: item['tag'],
                      count: currentCount,

                      // + 버튼: 새로운 아이템이면 추가, 이미 있으면 count++
                      onIncrease: () {
                        setState(() {
                          if (cartIndex == -1) {
                            cart.add({
                              'title': item['title'],
                              'price': item['price'],
                              'count': 1,
                              'imageUrl': item['imageUrl']
                            });
                          } else {
                            cart[cartIndex]['count'] = currentCount + 1;
                          }
                        });
                      },

                      // - 버튼: 0 이하 시 제거
                      onDecrease: () {
                        setState(() {
                          if (cartIndex == -1) return;
                          final next = currentCount - 1;
                          if (next <= 0) {
                            cart.removeAt(cartIndex);
                          } else {
                            cart[cartIndex]['count'] = next;
                          }
                        });
                      },

                      // 카드 클릭 → 메뉴 상세 다이얼로그 오픈
                      onTap: () {
                        final existingCount = currentCount == 0 ? 1 : currentCount;
                        showDialog(
                          context: context,
                          builder: (_) => MenuDetailDialog(
                            title: item['title'],
                            subtitle: item['subtitle'],
                            price: item['price'],
                            imageUrl: item['imageUrl'],
                            tagText: item['tag'],
                            initialCount: existingCount,
                            onAddToCart: (title, price, count) {
                              setState(() {
                                final i = cart.indexWhere((e) => e['title'] == title);
                                if (i == -1) {
                                  cart.add({'title': title, 'price': price, 'count': count});
                                } else {
                                  cart[i]['count'] = count;
                                }
                              });
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

          // 하단 장바구니 바
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: cart.isEmpty ? -100 : 0, // 장바구니 비었을 때 숨김
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 총합 정보
                  Text(
                    '총 $totalCount개\n${_formatWon(totalPrice)}원',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  // 장바구니 보기 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      // 오른쪽에서 나오는 슬라이드 팝업
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, __, ___) {
                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return CartSideSheet(
                                cartItems: cart,
                                totalPrice: totalPrice,

                                onIncrease: (title) {
                                  setState(() {
                                    final i = cart.indexWhere((e) => e['title'] == title);
                                    if (i != -1) cart[i]['count']++;
                                  });
                                  setStateDialog(() {}); // 팝업 내부 리렌더
                                },
                                onDecrease: (title) {
                                  setState(() {
                                    final i = cart.indexWhere((e) => e['title'] == title);
                                    if (i != -1) {
                                      cart[i]['count']--;
                                      if (cart[i]['count'] <= 0) cart.removeAt(i);
                                    }
                                  });
                                  setStateDialog(() {});
                                },
                                onRemove: (title) {
                                  setState(() => cart.removeWhere((e) => e['title'] == title));
                                  setStateDialog(() {});
                                },
                              );
                            },
                          );
                        },
                        transitionBuilder: (_, anim, __, child) {
                          final offset = Tween(begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
                          return SlideTransition(position: offset, child: child);
                        },
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    label: const Text('장바구니 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8751A),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // 단가 표시용 숫자 (천단위 콤마)
  String _formatWon(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final r = s.length - i;
      b.write(s[i]);
      if (i != s.length - 1 && (r - 1) % 3 == 0) b.write(',');
    }
    return b.toString();
  }
}
