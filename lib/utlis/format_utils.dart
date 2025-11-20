import 'package:intl/intl.dart';

final NumberFormat _wonFormatter = NumberFormat('#,###', 'ko_KR');
final DateFormat _timeFormatter = DateFormat('a hh:mm', 'ko_KR');

/// 숫자 관련 유틸 함수 [ ex) 1000000 => 1,000,000 ]
String formatWon(int value) {
  return _wonFormatter.format(value);
}

/// 시간 관련 유틸 함수[ ex) 오전 08:12 ]
String formatTime(DateTime dt) {
  return _timeFormatter.format(dt);
}
