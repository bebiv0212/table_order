import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/cart_provider.dart';
import 'package:table_order/utlis/format_utils.dart';

/// 장바구니 리스트 전체를 분리한 위젯.
/// (수량 조절 버튼 포함해서 전부 이 안에서 처리)
///
/// 상태는 CartProvider에서 관리되므로
/// 외부에서 cartItems / onIncrease / onDecrease / onRemove 등을 받을 필요 없음.
class CartCard extends StatelessWidget {
  const CartCard({super.key});

  @override
  Widget build(BuildContext context) {
    // CartProvider에서 장바구니 데이터 직접 가져오기
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;

    const accent = Color(0xFFE8751A);

    return ListView.separated(
      itemCount: cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
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
                    child: const Icon(LucideIcons.imageOff),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 상품명 / 단가 / 수량조절
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${formatWon(price)}원',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 수량 조절 (Provider 기반)
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
                          color: accent,
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
          color: color ?? Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color != null ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
