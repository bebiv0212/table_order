import 'package:flutter/material.dart';

enum OrderStatus { pending, done, paid }

extension OrderStatusExtension on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => '진행중',
    OrderStatus.done => '결제대기',
    OrderStatus.paid => '결제완료',
  };

  Color get backgroundColor => switch (this) {
    OrderStatus.pending => Color(0xFFF8F8F8),
    OrderStatus.done => Color(0xFFEBF8E8),
    OrderStatus.paid => Color(0xFFE8F4FF),
  };

  Color get textColor => switch (this) {
    OrderStatus.pending => Colors.black87,
    OrderStatus.done => Colors.green,
    OrderStatus.paid => Colors.blue,
  };
}
