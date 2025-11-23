import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';

class ReviewPreviewBox extends StatelessWidget {
  final List<dynamic> tags;
  final String title;
  final VoidCallback? onClose; // 고객쪽에서는 닫기 버튼 안쓸 수도 있음

  const ReviewPreviewBox({
    super.key,
    required this.tags,
    required this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // 상단 타이틀 + X 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),

              // 닫기 버튼이 필요 없는 경우 숨김
              onClose != null
                  ? GestureDetector(
                      onTap: onClose,
                      child: Icon(LucideIcons.x, color: Colors.black38),
                    )
                  : SizedBox(),
            ],
          ),

          Text(
            "어떠셨나요? 해당하는 태그를 선택해주세요.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          // 🔥 태그 그리드 뷰 (스크롤 가능)
          Expanded(
            child: GridView.builder(
              itemCount: tags.length,
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemBuilder: (context, index) {
                final tagName = tags[index];

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(tagName),
                );
              },
            ),
          ),

          // 버튼
          Container(
            width: double.infinity,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.customerPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "리뷰 등록",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
