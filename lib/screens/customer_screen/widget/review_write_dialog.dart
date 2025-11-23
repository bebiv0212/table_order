import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';

Future<void> showReviewWriteDialog({
  required BuildContext context,
  required String adminUid,
  required String menuId,
  required String menuName,
}) {
  final db = FirebaseFirestore.instance;
  final selected = <String>{};

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 450,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 상단 제목 + 닫기 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$menuName 리뷰 작성",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(LucideIcons.x, color: Colors.black38),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Text(
                    "어떠셨나요? 해당하는 태그를 선택해주세요.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  SizedBox(height: 20),

                  // 🔥 태그 GridView (스크롤 포함)
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
                          return Center(child: CircularProgressIndicator());
                        }

                        final tags = snapshot.data!.docs;

                        return GridView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: tags.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                      : Color(0xFFF7F7F7),
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

                  SizedBox(height: 20),

                  // 🔥 리뷰 등록 버튼 (고정)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () async {
                              final menuRef = db
                                  .collection("admins")
                                  .doc(adminUid)
                                  .collection("menus")
                                  .doc(menuId);

                              final menuDoc = await menuRef.get();

                              // 🔥 전체 데이터에서 안전하게 가져오기
                              final data = menuDoc.data();

                              // 🔥 reviews 없으면 빈 맵으로 대체 (오류 없음)
                              final oldReviews = Map<String, dynamic>.from(
                                data?["reviews"] ?? {},
                              );

                              // 선택한 태그 증가
                              for (final tag in selected) {
                                oldReviews[tag] = (oldReviews[tag] ?? 0) + 1;
                              }

                              await menuRef.update({"reviews": oldReviews});

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
