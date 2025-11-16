import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/cart_provider.dart';
import 'package:table_order/screens/customer_screen/widget/cart_card.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 오른쪽에서 슬라이드로 열리는 장바구니 패널.
///
/// 설계 이유:
/// - 상태는 부모에서 관리(state lifting) → CartSideSheet는 오직 ‘표시 + 이벤트 전달’만 담당.
/// - 전체를 StatelessWidget으로 둬서 매번 rebuild해도 부하가 적음(데이터만 주입받음).
class CartSideSheet extends StatelessWidget {
  const CartSideSheet({
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    // CartProvider로부터 현재 장바구니 상태 조회
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;
    final totalPrice = cart.totalPrice;
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
          width: MediaQuery
              .of(context)
              .size
              .width * 0.4,
          height: double.infinity,
          padding: EdgeInsets.all(20), // 내부 패딩: 콘텐츠 간 간격 확보.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (제목 , 닫기 버튼)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '장바구니',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // - 클릭 가능성 시각적으로 명확, 최소 터치 영역 자동 확보, ripple + focus 효과 기본 제공.
                  IconButton(
                    icon: Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context), // 모달 닫기
                  ),
                ],
              ),

              SizedBox(height: 10),

              // 장바구니 리스트
              Expanded(
                child: CartCard(),
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

                    // 주문 버튼
                    ElevatedButton(
                      onPressed: onOrder,
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