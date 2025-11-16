/// 통화/숫자 관련 유틸 함수 모음.
/// - intl 패키지 없이 간단히 천단위 콤마를 찍는 버전.
/// - ex: 1234567 → "1,234,567"
String formatWon(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final r = s.length - i;
    b.write(s[i]);
    if (i != s.length - 1 && (r - 1) % 3 == 0) b.write(',');
  }
  return b.toString();
}

String formatTime(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute;

  final isPm = hour >= 12;
  final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final ampm = isPm ? '오후' : '오전';

  return '$ampm ${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
