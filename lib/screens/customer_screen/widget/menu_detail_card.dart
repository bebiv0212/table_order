import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/menu_count_provider.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 메뉴 상세 다이얼로그
///
/// - 이 위젯은 "메뉴 하나의 상세 정보 + 수량 조절 + 장바구니 담기"를 보여주는 다이얼로그.
/// - 자기 자신은 StatelessWidget 이고, 수량(count) 상태는 MenuCountProvider가 관리.

class MenuDetailCard extends StatelessWidget {
  final String title;//메뉴 이름
  final String subtitle;//메뉴 설명
  final int price;//단가
  final String imageUrl;//메뉴 이미지
  final String? tagText;//카테고리 태그
  final void Function(String title, int price, int count)? onAddToCart;//장바구니에 담을 때 부모에게 알려줄 콜백
  final int initialCount;//다이얼 로그 처음 열릴때 기본 수량

  const MenuDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    this.tagText,
    this.onAddToCart,
    this.initialCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Provider 주입 (다이얼로그 단위)

    // - 다이얼로그 하나당 "독립적인 수량 상태"를 가지게 하기 위함.
    // - ChangeNotifierProvider를 다이얼로그 내부에 두면,
    //   이 다이얼로그 안에서만 MenuCountProvider가 살아있고,
    //   다른 메뉴 상세 다이얼로그와 상태가 섞이지 않는다.
    return ChangeNotifierProvider(
      // MenuCountProvider 생성하면서, 바로 reset(initialCount) 호출:
      // - 수량 초기값을 외부에서 주입받을 수 있도록 설계.
      create: (_) => MenuCountProvider()..reset(initialCount),
      child: Consumer<MenuCountProvider>(//로 수량 변경-> ui 업데이트
        builder: (context, countProvider, _) {
          final count = countProvider.count;//현재 선택된 수량
          final total = price * count;//총 금액=단가*수량

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            // insetPadding: 다이얼로그 양 옆/위 아래 여백 설정.
            // - 화면 가장자리에 딱 붙지 않고, 중앙에 적당한 크기로 보이게 하기 위함.
            insetPadding: EdgeInsets.symmetric(horizontal: 150, vertical: 40),
            child: SingleChildScrollView(
              child: SizedBox(
                height: 500,
                child: Row(
                   children: [
                    // 이미지
                    Expanded(
                      flex: 8,//왼쪽 영역 비율(3/7)
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(// 왼쪽만 둥글게(왼쪽 모서리만 radius 적용)
                          left: Radius.circular(18),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // 이미지 로딩 실패 시 대비용 UI
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(LucideIcons.imageOff),
                          ),
                        ),
                      ),
                    ),

                    // 내용
                    Expanded(
                      flex: 9,//오른쪽 영역 비율 (9/17)
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목 + 태그 + 닫기버튼
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Flexible로 감싸 overflow 방지:
                                      // - 제목이 너무 길어도 오른쪽 X 버튼을 침범하지 않게.
                                      Flexible(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 47,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // 태그가 있을 때만 표시
                                      if (tagText != null && tagText!.isNotEmpty)
                                        Container(
                                          margin: EdgeInsets.only(left: 23),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            tagText!,
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // 우측 상단 닫기 버튼 (X)
                                IconButton(
                                  icon: Icon(LucideIcons.x),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),

                            SizedBox(height: 30),

                            // 메뉴 설명 텍스트
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black54,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 60),

                            // 수량 조절
                            Row(
                              children: [
                                Text(
                                  '수량',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      //버튼
                                      IconButton(
                                        icon: Icon(LucideIcons.minus, size: 28),
                                        onPressed: countProvider.decrease,
                                      ),
                                      Text(
                                        '$count',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          LucideIcons.plus,
                                          color: AppColors.customerPrimary,
                                          size: 28,
                                        ),
                                        // Provider의 decrease()를 직접 호출:
                                        // - 수량이 1 이하로 내려가도 막을지 등 정책은
                                        //   MenuCountProvider 내부에서 관리하게 하기 위해.
                                        onPressed: countProvider.increase,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 14),

                            // 가격 / 총액
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${formatWon(price)}원',
                                  style: TextStyle(
                                    color: AppColors.customerPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  '총 ${formatWon(total)}원',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            Spacer(),//아래 버튼을 맨 밑으로 밀기 위해 추가

                            // 장바구니 담기 버튼
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  // 부모에 장바구니 담기 요청 (콜백 호출)
                                  // - 다이얼로그는 "장바구니에 담겠다"는 의도만 전달.
                                  // - 실제 CartProvider에 반영하는 책임은 외부(onAddToCart)에게 있음.
                                  onAddToCart?.call(title, price, count);
                                  Navigator.pop(context);// 다이얼로그 닫기
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.customerPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  '장바구니 담기',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
