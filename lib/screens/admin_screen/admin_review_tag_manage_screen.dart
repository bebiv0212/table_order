import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/services/review_tag_service.dart';
import 'package:table_order/screens/admin_screen/widget/review_preview_box.dart';

class AdminReviewTagManageScreen extends StatelessWidget {
  final String adminUid;
  final TextEditingController tagController = TextEditingController();

  AdminReviewTagManageScreen({super.key, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    final tagService = ReviewTagService(adminUid);

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "리뷰 태그 관리",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),

      body: StreamBuilder(
        stream: tagService.getTagStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tags = snapshot.data!.docs;

          return Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(80, 30, 80, 80),
              child: Row(
                spacing: 24,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------------------- 왼쪽 리뷰 미리보기 --------------------
                  Expanded(
                    flex: 4,
                    child: ReviewPreviewBox(
                      title: '리뷰화면 미리보기',
                      tags: tags.map((e) => e['name']).toList(),
                    ),
                  ),

                  // -------------------- 오른쪽 태그 관리 --------------------
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 30,
                      children: [
                        _descriptionBox(),

                        // 새 태그 추가
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            Text(
                              "새 태그 추가",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: tagController,
                                    decoration: InputDecoration(
                                      hintText: "태그 이름 입력 (예: 맛있어요, 친절해요)",
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final err = await tagService.addTag(
                                        tagController.text,
                                      );

                                      if (!context.mounted) return;

                                      if (err != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(err)),
                                        );
                                      } else {
                                        tagController.clear(); // ← 입력창 비우기
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.adminPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "추가",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 태그 목록
                        Text(
                          "현재 태그 목록 (${tags.length}개)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: tags.map((doc) {
                            final name = doc['name'];

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.adminBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.adminPrimary,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: AppColors.adminPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => tagService.deleteTag(doc.id),
                                    child: Icon(
                                      LucideIcons.x,
                                      size: 16,
                                      color: AppColors.adminPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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

  // -------------------- 설명 박스 --------------------
  Widget _descriptionBox() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: Colors.blue.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "리뷰 태그란?\n"
              "고객이 주문 완료 후 리뷰를 남길 때 선택할 수 있는 태그 목록입니다. "
              "여기서 태그를 추가하거나 삭제하면 고객 화면에 즉시 반영됩니다.",
              style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
