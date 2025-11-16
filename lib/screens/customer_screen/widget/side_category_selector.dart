import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/category_provider.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/rounded_rec_button.dart';

/// 고객 메뉴 화면 왼쪽 세로 카테고리 목록 (RoundedRecButton 적용 + 배경 애니메이션 유지)
class SideCategorySelector extends StatelessWidget {
  /// 표시할 카테고리 목록 (ex. ['전체', '메인', '음료', '디저트'])
  final List<String> categories;

  const SideCategorySelector({
    super.key,
    required this.categories, required String selectedCategory, required void Function(dynamic cat) onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final double itemHeight = 44.0;

    // Provider에서 현재 선택된 카테고리 가져오기
    final categoryProvider = context.watch<CategoryProvider>();
    final selectedCategory = categoryProvider.selected;

    return Container(
      width: 150,
      color: Color(0x10000000),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.customerPrimary : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              // 버튼 자체 배경은 투명 처리 → 바깥 컨테이너 색상만 부드럽게 전환
              child: SizedBox(
                height: itemHeight,
                width: double.infinity,
                child: RoundedRecButton(
                  text: cat,
                  onPressed: () {
                    // Provider state update
                    categoryProvider.select(cat);
                  },
                  bgColor: Colors.transparent, // 버튼 배경 제거 (애니메이션은 바깥에서)
                  fgColor: isSelected
                      ? Colors.white
                      : Color.fromARGB(222, 0, 0, 0), // ~0.87
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
