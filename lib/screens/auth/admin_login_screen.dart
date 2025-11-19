import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/auth_provider.dart' as my_auth;
import 'package:table_order/screens/admin_screen/admin_order_m_screen.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';

class AdminLoginScreen extends StatelessWidget {
  AdminLoginScreen({super.key});

  // ✔ Stateless에서도 controller 사용 가능
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<my_auth.AuthProvider>();

    return LoginForm(
      mode: AppMode.admin,
      title: '관리자 모드',
      subtitle: '매장 관리자 계정으로 로그인하세요',
      icon: LucideIcons.userCog,
      fields: [
        GreyTextField(
          controller: _email,
          label: '이메일',
          hint: 'admin@restaurant.com',
          obscure: false,
        ),
        GreyTextField(
          controller: _password,
          label: '비밀번호',
          hint: '********',
          obscure: true,
        ),
      ],
      onSubmit: () async {
        final email = _email.text.trim();
        final pw = _password.text.trim();

        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        final err = await auth.signInAdmin(email: email, password: pw);

        if (err != null) {
          messenger.showSnackBar(SnackBar(content: Text(err)));
          return;
        }

        final uid = FirebaseAuth.instance.currentUser!.uid;

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AdminOrderMScreen(adminUid: uid)),
          (route) => false,
        );
      },
      submitText: auth.loading ? '로그인 중...' : '로그인',
    );
  }
}
