import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/auth/admin_signup_screen.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/mode_container.dart';

class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(AppMode.customer),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 30,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Table Order',
                      style: TextStyle(
                        fontSize: 50, //
                        fontWeight: FontWeight.w600,
                        color: AppColors.customerPrimary,
                      ),
                    ),
                    Text(
                      '사용 모드를 선택해주세요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                Row(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ModeContainer(
                      modeTitle: '고객 모드', //
                      description: '테이블에서 메뉴를 주문합니다.',
                      btnText: '고객으로 시작하기',
                      mode: AppMode.customer,
                      icon: Icon(
                        LucideIcons.shoppingBag,
                        size: 50,
                        color: AppColors.customerPrimary,
                      ),
                    ), //
                    ModeContainer(
                      modeTitle: '관리자 모드', //
                      description: '주문과 메뉴를 관리 합니다.',
                      btnText: '관리자로 시작하기',
                      mode: AppMode.admin,
                      icon: Icon(
                        LucideIcons.userCog,
                        size: 50,
                        color: AppColors.adminPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('관리자 계정이 없으신가요?', style: TextStyle(fontSize: 18)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminSignupScreen(),
                          ),
                        );
                      },
                      child: Text('회원가입', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
