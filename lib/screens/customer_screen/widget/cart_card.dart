import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/cart_provider.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 장바구니의 목록 전체를 보여주는 카드 리스트 위젯.
///
/// - 이 위젯은 오직 UI + Provider 호출만 담당하게 하고,
///   상태(아이템 리스트, 수량 변경, 삭제)는 전부 CartProvider에 몰아 넣음.
/// - 이렇게 하면:
///   1) CartProvider만 바꿔도 장바구니 로직 전체가 동작
///   2) CartCard는 재사용하기 쉬운 프레젠테이션 전용 위젯이 됨.
class CartCard extends StatelessWidget {
  const CartCard({super.key});

  @override
  Widget build(BuildContext context) {
    // CartProvider에서 장바구니 데이터 가져오길
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;// 장바구니에 담긴 Map 리스트 (title, price, count 등)

    // - itemBuilder + separatorBuilder 를 분리해서, 카드 사이에 일정한 간격(SizedBox)을 깔끔하게 넣기 위함.
    // - ListView.builder + Padding으로 여백 넣는 것보다 의도가 더 명확하다.
    return ListView.separated(
      itemCount: cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // item은 Map<String, dynamic> 형태로 관리{ title: 메뉴 이름, price: 단가, count: 수량, imageUrl: 썸네일 주소 등}
        final item = cartItems[index];
        final title = item['title'];
        final price = item['price'] as int;
        final count = item['count'] as int;
        final image = item['imageUrl'] ?? '';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              // 이미지
              ClipRRect(
                //이미지 둥글게
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  // - 이미지 URL이 잘못됐거나 로딩 실패할 때 앱이 깨지는 걸 방지.(회색 박스 + 기본 아이콘)
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(LucideIcons.imageOff),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 상품명 / 단가 / 수량조절
              // - 중앙 영역이 가변적으로 늘어나도록 하기 위함.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //메뉴 이름
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    //단가
                    Text(
                      '${formatWon(price)}원',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 수량 조절 (+,-)
                    Row(
                      children: [
                        _QtyBtn(
                          icon: LucideIcons.minus,
                          onTap: () => cart.decreaseItem(item),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _QtyBtn(
                          icon: LucideIcons.plus,
                          color: AppColors.customerPrimary,
                          onTap: () =>cart.addItem(item),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 삭제 + 소계
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => cart.removeItem(title),
                    icon: const Icon(
                      LucideIcons.trash,
                      color: Colors.redAccent,
                    ),
                  ),
                  Text(
                    '${formatWon(price * count)}원',
                    style: const TextStyle(
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
    );
  }
}

/// 수량 조절 버튼 (+, −)
///
/// - + 버튼과 - 버튼의 스타일이 동일한데, 색만 바뀜.
/// - InkWell + Container 조합을 직접 쓰는 이유:
/// - IconButton보다 크기/모양/테두리/배경 컬러를 더 세밀하게 컨트롤하기 위해서
class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // - Material 위젯 계층에서 터치 시 잉크 리플 효과 제공
    // - 버튼처럼 보이게 시각적 피드백 제공
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          // color가 null이면 그냥 흰색 → - 버튼 같은 기본
          // color가 지정되어 있으면 (예: accent) → + 버튼 강조용
          color: color ?? Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          // 배경색이 있을 때는 아이콘 색을 흰색으로,
          // 없을 때는 기본 검정색으로 설정해서 대비 확보.
          color: color != null ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
