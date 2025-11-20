import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/enum/order_status.dart';
import 'package:table_order/providers/order_provider.dart';
import 'package:table_order/screens/admin_screen/admin_menu_manage_screen.dart';
import 'package:table_order/screens/admin_screen/widget/order_card.dart';
import 'package:table_order/screens/admin_screen/widget/order_list.dart';
import 'package:table_order/screens/admin_screen/widget/state_card.dart';
import 'package:table_order/utlis/format_utils.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';
import 'package:table_order/widgets/common_widgets/logout_button.dart';

class AdminOrderMScreen extends StatelessWidget {
  final String adminUid;

  const AdminOrderMScreen({super.key, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    // OrderProvider를 이 화면의 상태 관리용
    return ChangeNotifierProvider(
      create: (_) {
        final provider = OrderProvider();
        provider.loadShopName(adminUid);
        return provider;
      },
      child: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          // 현재 선택된 탭 상태
          final selectedStatus = provider.selectedStatus;

          return Scaffold(
            backgroundColor: Color(0xFFF7F7F7),

            appBar: CustomAppBar(
              storeName: provider.shopName.isEmpty
                  ? "불러오는 중…"
                  : "${provider.shopName} 관리",
              description: "실시간 주문 현황",
              actionBtn1: AppbarActionBtn(
                icon: LucideIcons.receiptText,
                title: '메뉴관리',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminMenuManageScreen(adminUid: provider.adminUid),
                    ),
                  );
                },
              ),
              actionBtn2: AppbarActionBtn(
                icon: LucideIcons.messageSquare,
                title: '리뷰관리',
                onPressed: () { debugPrint("리뷰관리 클릭"); },
              ),
              logoutBtn: LogoutButton(),
            ),

            body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('admins')
                        .doc(adminUid)
                        .collection('orders')
                        .doc(_todayId())
                        .collection('list')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.hasData ? snapshot.data!.docs : [];

                      /// 전체주문 건수
                      final totalOrders = docs.length;

                      /// 완료 건수
                      final doneOrders = docs
                          .where((d) => (d.data() as Map)['status'] == 'done')
                          .length;

                      /// 결제완료 건수
                      final paidOrders = docs
                          .where((d) => (d.data() as Map)['status'] == 'paid')
                          .length;

                      /// 총매출 계산
                      final int totalRevenue = docs
                          .where((d) => (d.data() as Map)['status'] == 'paid')
                          .fold(0, (sum, d) {
                        final price = (d.data() as Map)['totalPrice'];
                        return sum + (price as num).toInt();
                      });

                      return Row(
                        spacing: 10,
                        children: [
                          // 상태 카드
                          Expanded(
                            child: AdminStateCard(
                              title: "전체 주문",
                              orderCount: "$totalOrders건",
                            ),
                          ),
                          Expanded(
                            child: AdminStateCard(
                              title: "완료",
                              orderCount: "$doneOrders건",
                            ),
                          ),
                          Expanded(
                            child: AdminStateCard(
                              title: "결제완료",
                              orderCount: "$paidOrders건",
                            ),
                          ),
                          Expanded(
                            child: AdminStateCard(
                              title: "총 매출",
                              orderCount: "${formatWon(totalRevenue)}원",
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  // 탭버튼
                  Row(
                    children: OrderStatus.values.map((status) {
                      final isSelected = status == selectedStatus;

                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => provider.setStatus(status),
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.grey.shade400
                                    : Colors.transparent,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: Color.fromRGBO(158, 158, 158, 0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                                  : [],
                            ),
                            child: Text(
                              status.label,
                              style: TextStyle(
                                fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                                color:
                                isSelected ? Colors.black : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 20),

                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('admins')
                          .doc(adminUid)
                          .collection('orders')
                          .doc(_todayId())
                          .collection('list')
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;

                        final filteredDocs = docs.where((doc) {
                          final status = (doc.data() as Map)["status"];
                          if (selectedStatus == OrderStatus.table)
                            return status == "pending";
                          if (selectedStatus == OrderStatus.done)
                            return status == "done";
                          if (selectedStatus == OrderStatus.paid)
                            return status == "paid";
                          return false;
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return Center(child: Text("해당 주문이 없습니다"));
                        }

                        final Map<String, List<QueryDocumentSnapshot>> grouped = {};

                        for (final doc in filteredDocs) {
                          final table = (doc.data() as Map)["tableNumber"];
                          grouped.putIfAbsent(table, () => []);
                          grouped[table]!.add(doc);
                        }

                        return GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.80,
                          children: grouped.entries.map((entry) {
                            final tableNumber = entry.key;
                            final tableDocs = entry.value;

                            int sumPrice = 0;

                            final orderLists = tableDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              /// 주문 ID
                              final orderId = data["orderId"];

                              /// 총 금액
                              final int totalPrice =
                              (data["totalPrice"] as num).toInt();
                              sumPrice += totalPrice;

                              /// 주문 들어온 시간 저장
                              final createdAt =
                              (data["createdAt"] as Timestamp).toDate();

                              /// 주문 메뉴 리스트
                              final items =
                              List<Map<String, dynamic>>.from(data["items"]);

                              /// 주문 시간 형식
                              final timeStr =
                                  formatTime(createdAt);

                              /// 메뉴이름 x 메뉴개수
                              final menu = items
                                  .map((e) =>
                              "${e['name']} × ${e['quantity']}")
                                  .join(", ");

                              /// 주문 요약
                              return OrderList(
                                id: orderId,
                                time: timeStr,
                                price: "${formatWon(totalPrice)}원",
                                menu: menu,
                                onProcess: () =>
                                    _updateStatus(adminUid, orderId, "done"),
                                onPaid: () =>
                                    _updateStatus(adminUid, orderId, "paid"),
                                currentStatus: selectedStatus,
                              );
                            }).toList();

                            /// 카드 요약
                            final summary =
                                "${orderLists.length}건 - ${formatWon(sumPrice)}원";

                            return OrderCard(
                              tableName: "테이블 $tableNumber",
                              summary: summary,
                              status: selectedStatus,
                              onDelete: () {
                                for (final doc in tableDocs) {
                                  final orderId =
                                  (doc.data() as Map)["orderId"];
                                  _deleteOrder(adminUid, orderId);
                                }
                              },
                              orderLists: orderLists,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 오늘 날짜 ID
  String _todayId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// 상태 업데이트
  Future<void> _updateStatus(
      String adminUid, String id, String status) async {
    await FirebaseFirestore.instance
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(_todayId())
        .collection('list')
        .doc(id)
        .update({
      "status": status,
      "updatedAt": Timestamp.now(),
    });
  }

  /// 삭제
  Future<void> _deleteOrder(String adminUid, String id) async {
    await FirebaseFirestore.instance
        .collection('admins')
        .doc(adminUid)
        .collection('orders')
        .doc(_todayId())
        .collection('list')
        .doc(id)
        .delete();
  }
}
