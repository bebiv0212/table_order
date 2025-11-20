import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 개별 메뉴를 그리드/리스트에서 보여줄 때 사용하는 카드 위젯.
///
/// - 수량(count), 장바구니 추가/감소 로직은 전부 바깥(Provider/부모)에서 관리.
/// - 메뉴 정보(이미지/이름/설명/가격)를 예쁘게 보여주고 ,버튼 눌렸을 때 콜백만 전달하는 역할.
/// - 품절(isSoldOut) 상태에 따라 UI/인터랙션을 제어할 수 있도록 플래그 제공.
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.tagText,
    required this.count,

    /// 수량 증가 콜백 (예: 장바구니에 1개 추가)
    /// - nullable로 둔 이유: 어떤 상황에서는 + 버튼을 비활성화해야 할 수도 있어서.
    this.onIncrease,

    /// 수량 감소 콜백 (예: 장바구니에서 1개 제거)
    this.onDecrease,

    /// 카드 전체 탭 콜백 (예: 상세 보기 다이얼로그 열기)
    this.onTap,

    /// 품절 여부
    /// - true면 '품절' 뱃지 + 흐림 처리 + 버튼 숨김.
    this.isSoldOut = false,
  });

  ///메뉴 데이터
  final String imageUrl;
  final String title;
  final String subtitle;
  final int price;
  final String? tagText;

  /// 현재 선택된 수량 (부모 쪽에서 계산해서 내려줌)
  final int count;

  /// 콜백들 (외부 로직 연결)
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onTap;

  /// 품절 여부
  final bool isSoldOut;

  @override
  Widget build(BuildContext context) {
    final radius = 12.0; // 카드 모서리 둥글기 (여러 곳에서 쓰이기 때문에 변수로)

    return InkWell(
      // InkWell: 카드 전체에 터치 ripple 효과 주기 위해 사용.
      //
      // - isSoldOut이면 탭 불가능 (null)
      // - 아니면 onTap 콜백 호출
      onTap: isSoldOut ? null : onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Opacity(
        // 품절일 때 카드 전체를 살짝 흐리게(0.45)
        opacity: isSoldOut ? 0.45 : 1.0,
        child: Stack(
          children: [
            //카드 본체
            Card(
              elevation: 1, // 살짝 떠 있는 입체감
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              clipBehavior: Clip.antiAlias, // 이미지 모서리도 카드 라운드에 맞게 잘리도록
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 이미지
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover, // 카드 가로폭에 꽉 차게
                      // 이미지 로딩 실패 대비용
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          LucideIcons.imageOff,
                          size: 36,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),

                  /// 제목 + 태그
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Row(
                      children: [
                        // 제목은 가능한 한 많이 차지하도록 Expanded
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis, // 너무 길면 ... 처리
                          ),
                        ),

                        // 태그가 있을 때만 오른쪽에 조그맣게 표시
                        if (tagText != null && tagText!.isNotEmpty)
                          Container(
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

                  /// 설명
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(153, 0, 0, 0),
                      ),
                    ),
                  ),

                  Spacer(), // 위 내용과 아래 버튼 영역 사이의 여백 확보
                  /// 가격 + 버튼
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 4, 12, 10),
                    child: Row(
                      children: [
                        // 왼쪽: 가격
                        Expanded(
                          child: Text(
                            '${formatWon(price)}원',
                            style: TextStyle(
                              color: AppColors.customerPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        // 오른쪽: 수량/담기 UI (품절일 경우 전체 숨김)
                        if (!isSoldOut) ...[
                          // 아직 장바구니에 없는 상태(count == 0) → "담기" 버튼
                          if (count == 0)
                            ElevatedButton.icon(
                              // onIncrease는 nullable이지만,
                              // Flutter에서 onPressed: null 이면 버튼이 비활성화되므로
                              // 굳이 삼항 연산자로 나눌 필요 없이 그대로 전달.
                              onPressed: onIncrease,
                              icon: Icon(LucideIcons.plus, size: 14),
                              label: Text("담기"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.customerPrimary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          // count > 0 → 수량 조절 UI (- count +)
                          else
                            Container(
                              height: 36,
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(LucideIcons.minus),
                                    onPressed: onDecrease, // null이면 자동 비활성화
                                    iconSize: 18,
                                  ),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      LucideIcons.plus,
                                      color: AppColors.customerPrimary,
                                    ),
                                    onPressed: onIncrease, // null이면 자동 비활성화
                                    iconSize: 18,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 품절 표시
            if (isSoldOut)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "품절",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
