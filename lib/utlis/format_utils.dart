import 'package:intl/intl.dart';

final NumberFormat _wonFormatter = NumberFormat('#,###', 'ko_KR');
final DateFormat _timeFormatter = DateFormat('a hh:mm', 'ko_KR');

// 숫자 세자리마다 , 찍기
String formatWon(int value) {
  return _wonFormatter.format(value);
}

/// 시간 관련 유틸 함수
String formatTime(DateTime dt) {
  return _timeFormatter.format(dt);

  // final hour = dt.hour;
  // final minute = dt.minute;

  // final isPm = hour >= 12;
  // final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  // final ampm = isPm ? '오후' : '오전';

  // return '$ampm ${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
