import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/menu_count_provider.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';

class MenuDetailCard extends StatelessWidget {
  final String adminUid;
  final String menuId;
  final String title;
  final String subtitle;
  final int price;
  final String imageUrl;
  final String? tagText;
  final void Function(String title, int price, int count)? onAddToCart;
  final int initialCount;

  const MenuDetailCard({
    super.key,
    required this.adminUid,
    required this.menuId,
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
            child: SizedBox(
              height: 550,
              child: Row(
                children: [
                  // 왼쪽 이미지
                  Expanded(
                    flex: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Center(child: Icon(LucideIcons.imageOff)),
                      ),
                    ),
                  ),

                  // 오른쪽 내용
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 제목 + 태그 + 닫기
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (tagText != null &&
                                                tagText!.isNotEmpty)
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 23,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  tagText!,
                                                  style: TextStyle(
                                                    fontSize: 20,
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

                                  // 설명
                                  Expanded(
                                    child: Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),

                                  // 리뷰 TOP 3
                                  FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection("admins")
                                        .doc(adminUid)
                                        .collection("menus")
                                        .doc(menuId)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return SizedBox();

                                      final data = snapshot.data!.data();
                                      if (data == null) return SizedBox();

                                      final raw = data["reviews"];

                                      Map<String, dynamic> reviews;

                                      if (raw is Map<String, dynamic>) {
                                        reviews = raw;
                                      } else if (raw is Map) {
                                        reviews = raw.map(
                                          (key, value) =>
                                              MapEntry(key.toString(), value),
                                        );
                                      } else {
                                        reviews = {};
                                      }

                                      if (reviews.isEmpty) return SizedBox();

                                      final sorted = reviews.entries.toList()
                                        ..sort(
                                          (a, b) => (b.value as num).compareTo(
                                            a.value as num,
                                          ),
                                        );

                                      final top3 = sorted.take(3).toList();
                                      return Column(
                                        spacing: 10,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "고객 리뷰",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 5),
                                            child: Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: top3.map((e) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.black12,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        e.key,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        "(${e.value})",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: AppColors
                                                              .customerPrimary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  // 수량
                                  Row(
                                    spacing: 20,
                                    children: [
                                      Text(
                                        '수량',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                LucideIcons.minus,
                                                size: 20,
                                              ),
                                              onPressed: countProvider.decrease,
                                            ),
                                            Text(
                                              '$count',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                LucideIcons.plus,
                                                color:
                                                    AppColors.customerPrimary,
                                                size: 20,
                                              ),
                                              onPressed: countProvider.increase,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 가격
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${formatWon(price)}원',
                                        style: TextStyle(
                                          color: AppColors.customerPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        '총 ${formatWon(total)}원',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 담기 버튼
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        onAddToCart?.call(title, price, count);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.customerPrimary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '장바구니 담기',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
