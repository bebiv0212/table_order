import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/admin_screen/admin_review_tag_manage_screen.dart';
import 'package:table_order/screens/admin_screen/widget/admin_page_appbar.dart';
import 'package:table_order/theme/app_colors.dart';

class AdminReviewManageScreen extends StatelessWidget {
  final String adminUid;

  const AdminReviewManageScreen({super.key, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('admins')
          .doc(adminUid)
          .collection('menus')
          .snapshots(),
      builder: (context, snapshot) {
        // 로딩 중
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Color(0xFFF7F7F7),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final menus = snapshot.data!.docs;
        final menuCount = menus.length;

        return Scaffold(
          backgroundColor: Color(0xFFF7F7F7),

          appBar: AdminPageAppBar(
            title: '리뷰 관리',
            subtitle: '총 $menuCount개 메뉴',
            primaryActionLabel: '리뷰태그 관리',
            primaryActionIcon: LucideIcons.messageSquareDiff,
            onPrimaryAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AdminReviewTagManageScreen(adminUid: adminUid),
                ),
              );
            },
          ),

          body: ListView.separated(
            padding: EdgeInsets.all(20),
            itemCount: menus.length,
            separatorBuilder: (_, __) => SizedBox(height: 20),
            itemBuilder: (context, index) {
              final menuDoc = menus[index];
              final data = menuDoc.data();

              final menuName = data["name"] ?? "메뉴";
              final category = data["category"] ?? "기타";

              final reviewMap = Map<String, dynamic>.from(
                data["reviews"] ?? {},
              );

              final totalReviewCount = reviewMap.values.fold<int>(
                0,
                (total, v) => total + (v as num).toInt(),
              );

              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 제목 + 카테고리
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          menuName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    Text(
                      "총 $totalReviewCount개의 리뷰",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),

                    SizedBox(height: 12),

                    /// 리뷰 태그들
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: reviewMap.entries.map((entry) {
                        final label = entry.key;
                        final count = entry.value;

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF1E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.adminBg),
                          ),
                          child: Text(
                            "$label ($count)",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.adminPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
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
}
