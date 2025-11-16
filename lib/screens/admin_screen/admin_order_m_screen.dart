import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/screens/admin_screen/widget/order_card.dart';
import 'package:table_order/screens/admin_screen/widget/order_list.dart';
import 'package:table_order/screens/admin_screen/widget/state_card.dart';
import 'package:table_order/widgets/common_widgets/appbar_action_btn.dart';
import 'package:table_order/widgets/common_widgets/custom_appbar.dart';
import 'package:table_order/providers/order_provider.dart';
import 'package:table_order/enum/order_status.dart';

class AdminOrderMScreen extends StatelessWidget {
  final String shopName;
  const AdminOrderMScreen({super.key, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final currentStatus = provider.selectedStatus;
          final orders = provider.currentOrders;

          return Scaffold(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            appBar: CustomAppBar(
              storeName: '맛있는 식당 관리',
              description: '실시간 주문 현황',
              actionBtn1: AppbarActionBtn(
                icon: LucideIcons.receiptText,
                title: '메뉴관리',
              ),
              actionBtn2: AppbarActionBtn(
                icon: LucideIcons.messageSquare,
                title: '리뷰관리',
              ),
            ),

            // 더미데이터 추가용 버튼
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final prov = context.read<OrderProvider>();
                prov.addOrder(
                  "T3",
                  "김치찌개 x 1, 불고기 x 2",
                  prov.selectedStatus,
                );
              },
              child: Icon(Icons.add),
            ),

            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단 상태 카드
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        Expanded(
                          child: AdminStateCard(
                            title: "전체 주문",
                            order_count: "${provider.totalCount}건",
                          ),
                        ),
                        Expanded(
                          child: AdminStateCard(
                            title: "진행중",
                            order_count: "${provider.progressCount}건",
                          ),
                        ),
                        Expanded(
                          child: AdminStateCard(
                            title: "완료",
                            order_count: "${provider.doneCount}건",
                          ),
                        ),
                        Expanded(
                          child: AdminStateCard(
                            title: "결제완료",
                            order_count: "${provider.paidCount}건",
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // 탭 버튼
                    Row(
                      children: OrderStatus.values.map((status) {
                        final selected = status == currentStatus;
                        return Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => provider.setStatus(status),
                            child: Container(
                              height: 36,
                              margin: EdgeInsets.only(right: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? Colors.grey.shade400
                                      : Colors.transparent,
                                ),
                                boxShadow: selected
                                    ? [
                                  BoxShadow(
                                    color: Color.fromRGBO(158, 158, 158, 0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ]
                                    : [],
                              ),
                              child: Text(
                                status.label,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : Colors.grey[600],
                                  fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 30),

                    // 주문 카드 목록
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final orderItem = provider.filteredOrders[index];
                        final sampleLists = List.generate(
                          3,
                              (i) => OrderList(
                            time: "오후 ${6 + i}:0$i",       // 더미데이터
                            price: "${23000 + i * 1000}원",  // 더미데이터
                            menu: "된장찌개 × 1, 불고기 × 1",  // 더미데이터
                            onProcess: () {debugPrint("주문완료 버튼 클릭");},
                            onPaid: () {debugPrint("결제완료 버튼 클릭");},
                          ),
                        );

                        return OrderCard(
                          tableName: "테이블 ${orderItem.tableName}",
                          summary: "${sampleLists.length}건 · 64,000원",  // 가격 임시
                          status: orderItem.status,
                          onDelete: () => provider.deleteOrder(orderItem.id),
                          orderLists: sampleLists,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
