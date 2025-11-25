import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';

Future<void> showReviewWriteDialog({
  required BuildContext context,
  required String adminUid,
  required String menuId,
  required String menuName,

  // 🔥 리뷰 작성 후 주문 item에 reviewed:true 찍기 위해 추가된 정보들
  required String orderDateId, // 예: "2025-11-19"
  required String orderId, // list 문서 ID
  required int itemIndex, // items 배열에서 몇 번째인지
}) {
  final db = FirebaseFirestore.instance;
  final selected = <String>{};

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 450,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 제목 + 닫기 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$menuName 리뷰 작성",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(LucideIcons.x, color: Colors.black38),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "어떠셨나요? 해당하는 태그를 선택해주세요.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  // 태그 GridView (스크롤 포함)
                  SizedBox(
                    height: 250,
                    child: StreamBuilder(
                      stream: db
                          .collection("admins")
                          .doc(adminUid)
                          .collection("reviewTags")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final tags = snapshot.data!.docs;

                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: tags.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 3,
                              ),
                          itemBuilder: (context, index) {
                            final tagName = tags[index]["name"];
                            final isSelected = selected.contains(tagName);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSelected
                                      ? selected.remove(tagName)
                                      : selected.add(tagName);
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.customerPrimary.withAlpha(20)
                                      : const Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.customerPrimary
                                        : Colors.grey.shade300,
                                    width: 1.3,
                                  ),
                                ),
                                child: Text(
                                  tagName,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.customerPrimary
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 리뷰 등록 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () async {
                              // 1) 메뉴(foods) 쪽 리뷰 태그 누적
                              final menuRef = db
                                  .collection("admins")
                                  .doc(adminUid)
                                  .collection("menus")
                                  .doc(menuId);

                              final menuDoc = await menuRef.get();
                              final data = menuDoc.data();

                              final oldReviews = Map<String, dynamic>.from(
                                data?["reviews"] ?? {},
                              );

                              for (final tag in selected) {
                                oldReviews[tag] = (oldReviews[tag] ?? 0) + 1;
                              }

                              await menuRef.update({"reviews": oldReviews});

                              // 2) 주문(order) items 배열에서 해당 item에 reviewed:true 찍기
                              final orderRef = db
                                  .collection('admins')
                                  .doc(adminUid)
                                  .collection('orders')
                                  .doc(orderDateId)
                                  .collection('list')
                                  .doc(orderId);

                              final orderSnap = await orderRef.get();
                              final orderData = orderSnap.data();

                              if (orderData != null) {
                                final rawItems =
                                    (orderData['items'] ?? []) as List<dynamic>;

                                // List<Map<String, dynamic>> 형태로 변환
                                final items = rawItems
                                    .map(
                                      (e) =>
                                          Map<String, dynamic>.from(e as Map),
                                    )
                                    .toList();

                                if (itemIndex >= 0 &&
                                    itemIndex < items.length) {
                                  items[itemIndex]['reviewed'] = true;

                                  await orderRef.update({'items': items});
                                }
                              }

                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return AppColors.customerPrimary.withValues(
                              alpha: 0.4,
                            );
                          }
                          return AppColors.customerPrimary;
                        }),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "리뷰 등록",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
