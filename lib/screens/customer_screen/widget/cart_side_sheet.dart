import 'package:flutter/material.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 오른쪽에서 슬라이드로 열리는 장바구니 패널.
///
/// 설계 이유:
/// - 상태는 부모에서 관리(state lifting) → CartSideSheet는 오직 ‘표시 + 이벤트 전달’만 담당.
/// - 전체를 StatelessWidget으로 둬서 매번 rebuild해도 부하가 적음(데이터만 주입받음).
class CartSideSheet extends StatelessWidget {
  const CartSideSheet({
    super.key,
    required this.cartItems,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.totalPrice,
  });

  /// 부모에서 전달받은 장바구니 아이템 목록
  // Map<String, dynamic> 형태로 간단히 구성해 프로토타입 속도 확보.
  // 실제 서비스에서는 model class(예: CartItemModel)를 두면 안전성 높아짐.
  final List<Map<String, dynamic>> cartItems;

  /// 수량 +1 이벤트 콜백 (부모에서 실제 데이터 수정)
  final void Function(String title) onIncrease;

  /// 수량 -1 이벤트 콜백
  final void Function(String title) onDecrease;

  /// 항목 삭제 콜백
  final void Function(String title) onRemove;

  /// 총 결제 금액
  final int totalPrice;

  @override
  Widget build(BuildContext context) {
    // 포인트 컬러
    // 한 곳에서만 변경하면 전체 스타일이 바뀌게 하기 위해 const로 고정.
    const accent = Color(0xFFE8751A);

    return Align(
      alignment: Alignment.centerRight, // 패널을 화면 오른쪽 끝에 정렬.
      child: Material(
        // Material 위젯: elevation(그림자), ripple 효과 등 머티리얼 속성 사용 가능.
        // Container 단독보다 레이어 표현에 유리.
        color: Colors.white,
        elevation: 10, // 그림자를 통해 패널이 위로 떠 있는 느낌을 줌.
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        child: Container(
          // 패널 너비를 화면의 40%로 설정
          // 휴대폰은 0.9 정도로 조정 가능.
          width: MediaQuery.of(context).size.width * 0.4,
          height: double.infinity,
          padding: EdgeInsets.all(20), // 내부 패딩: 콘텐츠 간 간격 확보.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────────────────── 헤더 (제목 + 닫기 버튼)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '장바구니',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // - 클릭 가능성 시각적으로 명확, 최소 터치 영역(48dp) 자동 확보, ripple + focus 효과 기본 제공.
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context), // 모달 닫기
                  ),
                ],
              ),

              SizedBox(height: 10),

              // 장바구니 리스트
              Expanded(
                child: ListView.separated(
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final title = item['title'];
                    final price = item['price'] as int;
                    final count = item['count'] as int;
                    final image = item['imageUrl'] ?? '';

                    return Container(
                      // 개별 아이템 카드 영역
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          // 이미지 영역
                          // - ClipRRect로 라운드 처리.
                          // - errorBuilder를 넣어 네트워크 실패 시 안전하게 대체 아이콘 노출.
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // 상품명, 단가, 수량 조절
                          Expanded(
                            // Expanded: 우측 삭제/합계와 나란히 정렬 되며 남은 공간 모두 차지.
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목은 한 줄로 잘라 내고, bold로 강조.
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${formatWon(price)}원',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 6),

                                // 수량 조절: - [count] +
                                // InkWell + Container 커스텀 버튼을 쓴 이유:
                                // - IconButton은 여백이 커서 UI 공간을 많이 차지함.
                                // - 수량버튼은 작은 정사각형 형태가 자연스러워 직접 제작.
                                // - InkWell로 ripple 효과(피드백) 유지.
                                Row(
                                  children: [
                                    _QtyBtn(
                                      icon: Icons.remove,
                                      onTap: () => onDecrease(title),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _QtyBtn(
                                      icon: Icons.add,
                                      color: accent, // + 버튼만 포인트 컬러로 시각 강조
                                      onTap: () => onIncrease(title),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 삭제 버튼 + 합계 금액
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => onRemove(title),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: '삭제',
                              ),
                              // 단가 * 수량 = 소계
                              Text(
                                '${formatWon(price * count)}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 10),

              // 하단 결제 요약 영역
              Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 총 결제 금액
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 결제 금액',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          '${formatWon(totalPrice)}원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // 주문 버튼 (CTA).
                    ElevatedButton(
                      onPressed: () {
                        // 실제 주문 로직은 부모에서 수행.
                        // 여기서는 시각적 피드백만 간단히 표시.
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('주문하기 클릭됨')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent, // 브랜드 강조색
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('${formatWon(totalPrice)}원 주문하기'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 수량 조절 버튼 위젯 (±)
///
/// InkWell + Container 조합으로 구현.
///
/// 선택 이유:
/// - IconButton은 원형/크기 고정이라 직사각형 UI 만들기 어려움.
/// - 작은 버튼은 직접 사이즈 제어해야 터치 영역 일관성 확보.
/// - InkWell로 ripple 효과 유지 → 클릭 피드백 제공.
class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap, this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          // color가 null이면 흰 배경(감소 버튼),
          // 있으면 포인트 컬러(증가 버튼)로 구분.
          color: color ?? Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          // 포인트 버튼은 흰색 아이콘, 나머지는 기본 검정.
          color: color != null ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
