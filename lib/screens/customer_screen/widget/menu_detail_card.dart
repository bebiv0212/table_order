import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/menu_count_provider.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 메뉴 상세 다이얼로그 (Provider 기반 Stateless 버전)
class MenuDetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int price;
  final String imageUrl;
  final String? tagText;
  final void Function(String title, int price, int count)? onAddToCart;
  final int initialCount;

  const MenuDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    this.tagText,
    this.onAddToCart,
    this.initialCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Provider 주입 (다이얼로그 단위)
    return ChangeNotifierProvider(
      create: (_) => MenuCountProvider()..reset(initialCount),
      child: Consumer<MenuCountProvider>(
        builder: (context, countProvider, _) {
          final count = countProvider.count;
          final total = price * count;

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 150, vertical: 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SizedBox(
                        height: 160,
                        child: Center(child: Icon(LucideIcons.imageOff)),
                      ),
                    ),
                  ),

                  // 내용
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 + 태그 + 닫기버튼
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (tagText != null && tagText!.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(left: 8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tagText!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(LucideIcons.x),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),

                        SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 14),

                        // 수량 조절
                        Row(
                          children: [
                            Text(
                              '수량',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(LucideIcons.minus, size: 20),
                                    onPressed: countProvider.decrease,
                                  ),
                                  Text(
                                    '$count',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      LucideIcons.plus,
                                      color: AppColors.customerPrimary,
                                      size: 20,
                                    ),
                                    onPressed: countProvider.increase,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 14),

                        // 가격 / 총액
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${formatWon(price)}원',
                              style: TextStyle(
                                color: AppColors.customerPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '총 ${formatWon(total)}원',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18),

                        // 장바구니 담기 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              onAddToCart?.call(title, price, count);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$title이(가) 장바구니에 담겼습니다'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.customerPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '장바구니 담기',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
