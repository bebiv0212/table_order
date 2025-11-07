import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';

class AdminSignupScreen extends StatelessWidget {
  const AdminSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = AppMode.admin;

    return LoginBaseForm(
      mode: mode,
      title: '관리자 회원가입',
      subtitle: '새로운 매장을 등록하세요',
      icon: LucideIcons.userPlus,
      fields: const [
        GreyTextField(label: '가게 이름', hint: '우리 식당', obscure: false),
        GreyTextField(
          label: '관리자 이메일',
          hint: 'admin@email.com',
          obscure: false,
        ),
        GreyTextField(label: '비밀번호(6자리 이상)', hint: '********', obscure: true),
        GreyTextField(label: '비밀번호 확인', hint: '********', obscure: true),
      ],
      onSubmit: () {
        // TODO: 회원가입 처리
      },
      submitText: '회원가입',
    );
  }
}
