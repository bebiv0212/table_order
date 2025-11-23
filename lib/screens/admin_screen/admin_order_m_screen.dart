import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/enum/order_status.dart';
import 'package:table_order/providers/order_provider.dart';
import 'package:table_order/screens/admin_screen/admin_menu_manage_screen.dart';
import 'package:table_order/screens/admin_screen/admin_review_manage_screen.dart';
import 'package:table_order/screens/admin_screen/widget/order_card.dart';
import 'package:table_order/screens/admin_screen/widget/order_list.dart';
import 'package:table_order/screens/admin_screen/widget/state_card.dart';
import 'package:table_order/services/admin_service.dart';
import 'package:table_order/utlis/format_utils.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';
import 'package:table_order/widgets/common_widgets/logout_button.dart';

class AdminOrderMScreen extends StatelessWidget {
  final String adminUid;

  const AdminOrderMScreen({super.key, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    final service = AdminService();

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminReviewManageScreen(adminUid: adminUid),
                    ),
                  );
                },
              ),
              logoutBtn: LogoutButton(),
            ),

            body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  /// ✅ 위쪽 : 상태 카드 (접기/펼치기)
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('admins')
                        .doc(adminUid)
                        .collection('orders')
                        .doc(provider.todayId)
                        .collection('list')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.hasData ? snapshot.data!.docs : [];

                      /// 전체주문 건수
                      final pendingOrders = docs
                          .where(
                            (d) => (d.data() as Map)['status'] == 'pending',
                      )
                          .length;

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
                          .fold(0, (total, d) {
                        final price = (d.data() as Map)['totalPrice'];
                        return total + (price as num).toInt();
                      });

                      return ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        initiallyExpanded: true,

                        title: Text(
                          "상태카드 접기/펼치기",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: AdminStateCard(
                                  title: "진행중",
                                  orderCount: "$pendingOrders건",
                                ),
                              ),
                              Expanded(
                                child: AdminStateCard(
                                  title: "결제대기",
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
                              Expanded(
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('admins')
                                      .doc(adminUid)
                                      .collection('staffCalls')
                                      .where('status', isEqualTo: 'pending')
                                      .snapshots(),
                                  builder: (context, staffSnapshot) {
                                    final count =
                                    staffSnapshot.hasData ? staffSnapshot.data!.docs.length : 0;

                                    final bool hasCall = count > 0;

                                    return AdminStateCard(
                                      title: "직원 호출",
                                      orderCount: "$count건",
                                      icon: Icon(
                                        LucideIcons.bellRing,
                                        color: hasCall ? Colors.red : Colors.grey,
                                        size: 30,
                                      ),

                                      // 추가: 카드 색상 커스텀
                                      backgroundColor: hasCall ? Color(0xFFFFF1F1) : Colors.white,
                                      borderColor: hasCall ? Colors.red.shade200 : Colors.grey.shade300,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  /// 아래쪽 전체를 하나의 스크롤 영역으로
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          /// 직원 호출 리스트
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('admins')
                                .doc(adminUid)
                                .collection('staffCalls')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox();
                              }

                              // pending만 필터링
                              final pendingCalls = snapshot.data!.docs.where(
                                    (d) =>
                                (d.data() as Map)['status'] == 'pending',
                              ).toList();

                              if (pendingCalls.isEmpty) {
                                return SizedBox();
                              }

                              return Column(
                                children: pendingCalls.map((doc) {
                                  final data = doc.data()
                                  as Map<String, dynamic>;

                                  final callType = data['callType'];
                                  final label =
                                  service.staffCallLabel(callType);
                                  final table = data['tableNumber'];
                                  final createdAt =
                                  (data['createdAt'] as Timestamp)
                                      .toDate();

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.shade100,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.bellRing,
                                              color: Colors.red,
                                              size: 26,
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "테이블 $table - $label",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  formatTime(createdAt),
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // 완료 버튼
                                        ElevatedButton(
                                          onPressed: () async {
                                            await service.deleteStaffCall(
                                              adminUid: adminUid,
                                              callId: doc.id,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding:
                                            EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 10,
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Text(
                                            "완료",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          SizedBox(height: 20),

                          /// 탭 버튼
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
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.grey.shade400
                                            : Colors.transparent,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                            158,
                                            158,
                                            158,
                                            0.3,
                                          ),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: Text(
                                      status.label,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: 20),

                          /// 주문 리스트 (Grid)
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('admins')
                                .doc(adminUid)
                                .collection('orders')
                                .doc(provider.todayId)
                                .collection('list')
                                .orderBy("createdAt", descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final docs = snapshot.data!.docs;

                              final filteredDocs = docs.where((doc) {
                                final status =
                                (doc.data() as Map)["status"];
                                if (selectedStatus == OrderStatus.pending) {
                                  return status == "pending";
                                }
                                if (selectedStatus == OrderStatus.done) {
                                  return status == "done";
                                }
                                if (selectedStatus == OrderStatus.paid) {
                                  return status == "paid";
                                }
                                return false;
                              }).toList();

                              if (filteredDocs.isEmpty) {
                                return Center(
                                  child: Text("해당 주문이 없습니다"),
                                );
                              }

                              final Map<String,
                                  List<QueryDocumentSnapshot>> grouped = {};

                              for (final doc in filteredDocs) {
                                final table =
                                (doc.data() as Map)["tableNumber"];
                                grouped.putIfAbsent(table, () => []);
                                grouped[table]!.add(doc);
                              }

                              return GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                                shrinkWrap: true,
                                physics:
                                NeverScrollableScrollPhysics(),
                                children: grouped.entries.map((entry) {
                                  final tableNumber = entry.key;
                                  final tableDocs = entry.value;

                                  int sumPrice = 0;

                                  final orderLists = tableDocs.map((doc) {
                                    final data = doc.data()
                                    as Map<String, dynamic>;

                                    /// 주문 ID
                                    final orderId = data["orderId"];

                                    /// 총 금액
                                    final int totalPrice =
                                    (data["totalPrice"] as num).toInt();
                                    sumPrice += totalPrice;

                                    /// 주문 들어온 시간 저장
                                    final createdAt =
                                    (data["createdAt"] as Timestamp)
                                        .toDate();

                                    /// 주문 메뉴 리스트
                                    final items =
                                    List<Map<String, dynamic>>.from(
                                      data["items"],
                                    );

                                    /// 주문 시간 형식
                                    final timeStr = formatTime(createdAt);

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
                                      onProcess: () => service.updateStatus(
                                        adminUid: adminUid,
                                        orderId: orderId,
                                        newStatus: "done",
                                      ),
                                      onPaid: () => service.updateStatus(
                                        adminUid: adminUid,
                                        orderId: orderId,
                                        newStatus: "paid",
                                      ),
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
                                        final data = doc.data()
                                        as Map<String, dynamic>;
                                        final orderId = data["orderId"];

                                        service.deleteOrder(
                                          adminUid: adminUid,
                                          orderId: orderId,
                                        );
                                      }
                                    },
                                    orderLists: orderLists,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
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
}
