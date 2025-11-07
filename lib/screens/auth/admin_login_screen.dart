import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/admin_screen/admin_order_m_screen.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginBaseForm(
      mode: AppMode.admin,
      title: '관리자 모드',
      subtitle: '매장 관리자 계정으로 로그인하세요',
      icon: LucideIcons.userCog,
      fields: const [
        GreyTextField(
          label: '이메일',
          hint: 'admin@restaurant.com',
          obscure: false,
        ),
        GreyTextField(label: '비밀번호', hint: '********', obscure: true),
      ],
      onSubmit: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminOrderMScreen()),
        );
      },
      submitText: '로그인',
    );
  }
}
