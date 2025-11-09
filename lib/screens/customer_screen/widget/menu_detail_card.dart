import 'package:flutter/material.dart';

/// 개별 메뉴를 눌렀을 때 나오는 상세 정보 다이얼로그.
///
/// - StatelessDialog 대신 Stateful로 구성한 이유: 수량 변경 시 setState 필요.
/// - UI와 데이터 로직(수량 카운트, 담기 이벤트)을 하나의 모달 내에서 처리.
/// - 상위 부모는 콜백으로 결과만 받음 → "UI 독립성" 확보.
///
/// - Gesture 영역이 명확해서 실수 입력이 적음.
class MenuDetailDialog extends StatefulWidget {
  final String title;     // 메뉴 이름
  final String subtitle;  // 설명
  final int price;        // 단가
  final String imageUrl;  // 이미지 경로(URL)
  final String? tagText;  // 예: "음료", "디저트" 같은 카테고리 표시

  /// 부모로부터 받은 콜백
  /// - 사용자가 "담기"를 누르면 (title, price, count)을 전달.
  final void Function(String title, int price, int count)? onAddToCart;

  /// 초기 수량 (이미 장바구니에 담긴 경우 수량 유지)
  final int initialCount;

  const MenuDetailDialog({
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
  State<MenuDetailDialog> createState() => _MenuDetailDialogState();
}

class _MenuDetailDialogState extends State<MenuDetailDialog> {
  late int _count; // 내부 상태 (현재 선택한 수량)

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount; // 이미 담긴 수량이 있다면 그대로 유지.
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8751A); // 브랜드 포인트 컬러 (버튼, 가격 강조용)
    final total = widget.price * _count; // 현재 수량 기준 총액 계산

    return Dialog(
      // - AlertDialog보다 자유로운 커스텀 가능, RoundedRectangleBorder로 모서리 둥글게 만들기, insetPadding으로 화면 중앙에 적당히 여백 확보
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 150, vertical: 40),

      child: SingleChildScrollView(
        // - 화면이 작거나 내용이 길 때 스크롤 가능하게 처리, 특히 웹/태블릿 환경에서 오버플로우 방지.
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용 크기에 맞춤
          children: [
            //이미지 영역
            // ClipRRect: 위쪽 모서리만 둥글게 → Dialog 전체 디자인 일관성 유지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                widget.imageUrl,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover, // 이미지가 영역에 맞게 채워짐
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 160,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),

            // 내용 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 태그 + 닫기 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // 메뉴 이름: Flexible로 긴 제목도 잘림 없이 표시
                            Flexible(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // 태그: 부가정보(메인, 음료 등)를 작게 표시
                            if (widget.tagText != null && widget.tagText!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.tagText!,
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

                      // 닫기 버튼 (IconButton을 쓴 이유: 직관 + 터치 영역 보장)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  // 부제(설명)
                  Text(
                    widget.subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
                  ),

                  const SizedBox(height: 14),

                  // 수량 조절 영역
                  Row(
                    children: [
                      const Text('수량',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),

                      // 수량 조절 박스
                      // IconButton은 Padding이 커서 Container로 감싸 여백 통일.
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // - 버튼
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () {
                                if (_count > 1) setState(() => _count--);
                              },
                            ),

                            // 현재 수량 표시
                            Text('$_count', style: const TextStyle(fontSize: 15)),

                            // + 버튼 (accent로 강조)
                            IconButton(
                              icon: const Icon(Icons.add, color: accent, size: 20),
                              onPressed: () => setState(() => _count++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 가격 & 총액 영역
                  // 좌: 단가 강조 / 우: 총액 강조
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatWon(widget.price)}원',
                        style: const TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '총 ${_formatWon(total)}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // “장바구니 담기” 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    // - RaisedButton은 deprecated → ElevatedButton이 대체, 장바구니 담기 액션은 입체감 필요.
                    child: ElevatedButton(
                      onPressed: () {
                        // 부모로 콜백 전달 → 상위 상태 갱신.
                        widget.onAddToCart?.call(widget.title, widget.price, _count);

                        // 다이얼로그 닫기 + 피드백 스낵바 표시
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.title}이(가) 장바구니에 담겼습니다'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent, // 브랜드 포인트 컬러
                        foregroundColor: Colors.white, // 텍스트 대비
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '장바구니 담기',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 간단한 천단위 콤마 포맷 함수
  //- intl 패키지 없이 빠르고 가볍게 처리
  //- 12345 → "12,345"
  String _formatWon(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final r = s.length - i;
      b.write(s[i]);
      final last = i == s.length - 1;
      final comma = !last && (r - 1) % 3 == 0;
      if (comma) b.write(',');
    }
    return b.toString();
  }
}
