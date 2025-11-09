import 'package:flutter/material.dart';

/// 고객 메뉴 화면(예: 카페 주문 페이지)의 왼쪽 사이드에 세로 카테고리 목록을 표시.
///
///
/// 구조적 특징:
/// 1. 상태는 외부에서 관리 (selectedCategory, onCategorySelected), UI이만 함.
/// 2. AnimatedContainer로 선택 상태 전환 시 부드러운 색 변화 제공.
class SideCategorySelector extends StatelessWidget {
  /// 표시할 카테고리 목록 (ex. ['전체', '메인', '음료', '디저트'])
  final List<String> categories;

  /// 현재 선택된 카테고리 (부모에서 관리)
  final String selectedCategory;

  /// 사용자가 특정 카테고리를 탭했을 때 실행되는 콜백
  final ValueChanged<String> onCategorySelected;

  const SideCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // 주황색: 메인 컬러 (선택 강조)
    const selectedColor = Color(0xFFE8751A);
    // 회색: 기본 배경 (비선택 상태)
    const unselectedColor = Color(0xFFF3F3F3);

    return Container(
      // 고정 너비: 세로 메뉴 바 영역 (좌측 1열)
      width: 90,
      color: Colors.white, // 전체 배경 흰색 (시각적 경계 분리)

      // ListView로 스크롤 가능하게 구성
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),

            // GestureDetector: 단순 탭 이벤트만 필요하므로 InkWell보다 가벼움.
            // (InkWell은 ripple 효과 + Material 의존 필요)
            child: GestureDetector(
              onTap: () => onCategorySelected(cat),

              // AnimatedContainer: 선택 시 색상 변경을 부드럽게 애니메이션 처리.
              // (즉각적인 깜빡임 대신 자연스러운 전환)
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : unselectedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),

                // 중앙 정렬된 카테고리 텍스트
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      // 선택 상태에 따라 색상 반전
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500, // 강조 vs 기본
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
