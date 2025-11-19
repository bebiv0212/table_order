import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/models/menu_model.dart';
import 'package:table_order/theme/app_colors.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu; // 이 카드가 표시할 메뉴 데이터
  final VoidCallback onEdit; // 수정 버튼 눌렀을 때 실행할 콜백
  final VoidCallback onDelete; // 삭제 버튼 눌렀을 때 실행할 콜백

  const MenuCard({
    super.key,
    required this.menu,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드 전체 박스 스타일
      decoration: BoxDecoration(
        color: Colors.white, // 카드 배경색
        borderRadius: BorderRadius.circular(14), // 모서리 둥글게
        boxShadow: [
          // 살짝 떠 있는 느낌용 그림자
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14, 14, 14, 0), // 카드 안쪽 여백
      child: Column(
        children: [
          Row(
            spacing: 14,
            children: [
              // 🔹 왼쪽: 메뉴 사진
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // 이미지 모서리 둥글게
                child: Image.network(
                  menu.imageUrl, // 메뉴 이미지 URL
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover, // 이미지 비율 유지하면서 꽉 채우기
                ),
              ),

              // 🔹 오른쪽: 텍스트/스위치/버튼 영역
              Expanded(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메뉴 이름
                    Text(
                      menu.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 메뉴 설명 (한 줄만 보이게, 길면 ... 처리)
                    Text(
                      menu.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 가격 (포인트 컬러)
                    Text(
                      "${menu.price}원",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.adminPrimary, // 관리자 메인 색상
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // 판매중 스위치 (현재는 UI만, 실제 동작은 나중에 연결)
                    Row(
                      children: [
                        CupertinoSwitch(
                          activeTrackColor: AppColors.adminPrimary,
                          inactiveTrackColor: Colors.grey,
                          value: menu.isAvailable, // true면 스위치 ON
                          onChanged: (_) {
                            // TODO: 나중에 판매 상태 바꾸는 로직 연결
                          },
                        ),
                        Text("판매중"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 수정 / 삭제 버튼 줄
          Row(
            children: [
              // 수정 버튼
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit, // 상위에서 넘겨준 콜백 실행
                  icon: const Icon(LucideIcons.pen),
                  label: const Text("수정"),
                ),
              ),

              // 삭제 아이콘 버튼
              IconButton(
                onPressed: onDelete, // 상위에서 넘겨준 콜백 실행
                icon: const Icon(LucideIcons.trash, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
