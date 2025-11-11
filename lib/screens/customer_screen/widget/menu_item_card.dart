import 'package:flutter/material.dart';

/// 메뉴 리스트에서 개별 메뉴를 보여주는 카드 UI.
///
/// - 메뉴 이미지, 제목, 설명, 가격, 태그, 수량조절 버튼을 포함.
/// - 수량 상태(count)는 부모(상위 화면)에서 관리하며, 이 위젯은 표시/콜백만 담당.
/// - 수량이 0이면 ‘담기’ 버튼으로, 1 이상이면 수량조절 UI(-, count, +)로 전환.
///
/// - 빠른 터치 UX (InkWell)
/// - 정보 위계: 이미지 → 제목 → 설명 → 가격/버튼 순으로 시각적 흐름.
/// - 카드 단위로 깔끔하게 분리하여 GridView 등에서 반복적으로 사용 가능.
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.tagText,
    required this.count,         // 현재 수량 (외부에서 내려받음)
    required this.onIncrease,    // + 눌렀을 때 콜백
    required this.onDecrease,    // - 눌렀을 때 콜백
    this.onTap,                  // 카드 전체 터치 시 콜백 (상세보기 등)
  });

  final String imageUrl;   // 메뉴 이미지
  final String title;      // 메뉴 제목
  final String subtitle;   // 메뉴 설명
  final int price;         // 단가
  final String? tagText;   // 카테고리 태그 (ex. 음료, 디저트 등)

  final int count;         // 현재 수량
  final VoidCallback onIncrease;  // + 콜백
  final VoidCallback onDecrease;  // - 콜백
  final VoidCallback? onTap;      // 상세 클릭 콜백

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8751A); // 브랜드 포인트 컬러
    const radius = 12.0;              // 카드 라운드 정도

    return InkWell(
      // InkWell: 카드 전체에 ripple 효과 부여 → 누를 수 있다는 시각적 피드백
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),

      child: Card(
        elevation: 1, // 살짝 떠있는 입체감
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        clipBehavior: Clip.antiAlias, // 이미지 모서리 잘림 방지
        child: SizedBox.expand(
          // SizedBox.expand: 부모 Grid 셀 크기에 자동 맞춤
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 영역
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // 이미지 꽉 채움
                  // errorBuilder: 이미지 로드 실패 대비
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 36, color: Colors.black45),
                  ),
                ),
              ),

              // 제목 + 태그
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis, // 긴 제목 잘라냄
                      ),
                    ),
                    // 태그가 있을 경우만 표시
                    if (tagText != null && tagText!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tagText!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 설명 영역
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),

              const Spacer(), // 남는 공간 밀어 내기

              // 가격 + 수량 조절/담기
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  children: [
                    // 가격 표시
                    Expanded(
                      child: Text(
                        '${_formatWon(price)}원',
                        style: const TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    // count == 0 → ‘담기’ 버튼
                    // count > 0 → 수량 조절 (-, count, +)
                    if (count == 0)
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: onIncrease, // 최초 클릭 시 1개 담기
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('담기', style: TextStyle(fontSize: 13)),

                          // - 담기는 첫 액션(Primary Action) → 강조 필요, OutlinedButton이나 TextButton보다 명확한 CTA, elevation=0으로 납작하게 만들어 too-heavy 느낌 방지.
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0, // 플랫한 디자인
                          ),
                        ),
                      )
                    else
                    // 수량 조절 UI ( -  count  + )
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // - 버튼
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              // IconButton을 쓴 이유:
                              // • 터치 영역 자동 확보(48dp)
                              // • InkWell보다 간단하게 ripple 및 hover 처리
                              onPressed: onDecrease,
                            ),

                            // 현재 수량 텍스트
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // + 버튼
                            IconButton(
                              icon: const Icon(Icons.add, color: accent, size: 18),
                              onPressed: onIncrease,
                            ),
                          ],
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

  /// 단가 표시용 숫자 포맷터 (ex: 12345 → 12,345)
  // - intl 패키지 없이 간단히 구현.
  // - 성능/의존성 측면에서 프로토타입 단계에 적합.
  String _formatWon(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final r = s.length - i;
      b.write(s[i]);
      if (i != s.length - 1 && (r - 1) % 3 == 0) b.write(',');
    }
    return b.toString();
  }
}
