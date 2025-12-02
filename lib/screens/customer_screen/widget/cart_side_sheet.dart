import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/cart_provider.dart';
import 'package:table_order/screens/customer_screen/widget/cart_card.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 오른쪽에서 슬라이드로 열리는 장바구니 패널.
///
/// 설계 이유:
/// - CartProvider에서 정보 관리 → CartSideSheet는 표시 + 이벤트 전달
class CartSideSheet extends StatelessWidget {
  const CartSideSheet({super.key, required this.onOrder});

  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    // CartProvider로부터 현재 장바구니 상태 조회
    // - context.watch<CartProvider>() 를 사용해서
    //   CartProvider의 notifyListeners()가 호출될 때마다
    //   → 이 위젯도 자동으로 리빌드(총 금액, 리스트 등 갱신).
    final cart = context.watch<CartProvider>();
    final totalPrice = cart.totalPrice;

    return Align(
      // Align을 사용하는 이유:
      // - 이 CartSideSheet가 보통 showGeneralDialog로 전체 화면 위에 올라가는데,
      //   그 안에서 오른쪽 끝에 패널을 붙이고 싶기 때문.
      alignment: Alignment.centerRight, // 패널을 화면 오른쪽 끝에 정렬.
      child: Material(
        // Material 위젯: elevation(그림자), ripple 효과 등 머티리얼 속성 사용 가능.
        // Container 단독보다 레이어 표현에 유리.
        color: Colors.white,
        elevation: 10, // 그림자(패널이 위로 떠 있는 느낌을 줌)
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
              // 헤더 (제목 , 닫기 버튼)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '장바구니',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  //닫기 버튼
                  // - 클릭 가능성 시각적으로 명확, 최소 터치 영역 자동 확보, ripple + focus 효과 기본 제공.
                  IconButton(
                    icon: Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context), // 모델 닫기
                  ),
                ],
              ),

              SizedBox(height: 10),

              // 장바구니 리스트
              // - 위에는 헤더, 아래에는 결제 요약 + 버튼이 있고, 그 사이 영역을 리스트가 가능한 만큼 꽉 채우도록 하기 위함.
              // - 내부의 CartCard가 ListView를 기반으로 스크롤 처리 담당.
              Expanded(child: CartCard()),

              SizedBox(height: 10),

              // 하단 결제 요약 영역
              Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  //위쪽에만 얇은 선을 넣어 리스트와 시각적으로 구분
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
                          //formatWon: 숫자를 1,000 처럼 포맷팅 해주는 유틸 함수.
                          '총 결제 금액',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          '${formatWon(totalPrice)}원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.customerPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // 주문 버튼
                    // 이 onPressed는 CartSideSheet가 직접 처리하지 않고,
                    // 부모에서 주입해준 onOrder 콜백만 호출한다.
                    ElevatedButton(
                      onPressed: onOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.customerPrimary, // 브랜드 강조색
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${formatWon(totalPrice)}원 주문하기',
                        style: TextStyle(color: Colors.white),
                      ),
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
