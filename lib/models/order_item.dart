import '../enum/order_status.dart';

class OrderItem {
  final String id;
  final String tableName;
  final String menuSummary;
  final OrderStatus status;
  final DateTime time;

  OrderItem({
    required this.id,
    required this.tableName,
    required this.menuSummary,
    required this.status,
    required this.time,
  });
}
