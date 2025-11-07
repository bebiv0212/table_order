import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/screens/customer_screen/customer_menu_screen.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginBaseForm(
      mode: AppMode.customer,
      title: '고객 주문하기',
      subtitle: '관리자 정보와 테이블 번호를 입력하세요',
      icon: LucideIcons.shoppingBag,
      fields: const [
        GreyTextField(
          label: '관리자 이메일',
          hint: 'admin@email.com',
          obscure: false,
        ),
        GreyTextField(label: '비밀번호', hint: '********', obscure: true),
        GreyTextField(
          label: '테이블 번호',
          hint: '예: 01, 02, 03...',
          obscure: false,
        ),
      ],
      onSubmit: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CustomerMenuScreen()),
        );
      },
      submitText: '주문 시작하기',
    );
  }
}
