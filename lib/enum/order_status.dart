import 'package:flutter/material.dart';

enum OrderStatus { table, progress, done, paid }

extension OrderStatusExtension on OrderStatus {
  String get label => switch (this) {
    OrderStatus.table => '테이블별',
    OrderStatus.progress => '진행중',
    OrderStatus.done => '완료',
    OrderStatus.paid => '결제완료',
  };

  Color get backgroundColor => switch (this) {
    OrderStatus.table => Color(0xFFF8F8F8),
    OrderStatus.progress => Color(0xFFFFF4E5),
    OrderStatus.done => Color(0xFFEBF8E8),
    OrderStatus.paid => Color(0xFFE8F4FF),
  };

  Color get textColor => switch (this) {
    OrderStatus.table => Colors.black87,
    OrderStatus.progress => Colors.orange,
    OrderStatus.done => Colors.green,
    OrderStatus.paid => Colors.blue,
  };
}
