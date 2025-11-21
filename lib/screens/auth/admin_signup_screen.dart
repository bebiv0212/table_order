import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/auth_provider.dart' as my_auth;
import 'package:table_order/screens/admin_screen/admin_order_m_screen.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';

class AdminSignupScreen extends StatelessWidget {
  AdminSignupScreen({super.key});

  final _shop = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pwCheck = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<my_auth.AuthProvider>();

    return LoginForm(
      mode: AppMode.admin,
      title: '관리자 회원가입',
      subtitle: '새로운 매장을 등록하세요',
      icon: LucideIcons.userPlus,
      fields: [
        GreyTextField(
          controller: _shop,
          label: '가게 이름',
          hint: '우리 식당',
          obscure: false,
        ),
        GreyTextField(
          controller: _email,
          label: '관리자 이메일',
          hint: 'admin@email.com',
          obscure: false,
        ),
        GreyTextField(
          controller: _pw,
          label: '비밀번호 (6자리 이상)',
          hint: '********',
          obscure: true,
        ),
        GreyTextField(
          controller: _pwCheck,
          label: '비밀번호 확인',
          hint: '********',
          obscure: true,
        ),
      ],
      onSubmit: () async {
        final shop = _shop.text.trim();
        final email = _email.text.trim();
        final pw = _pw.text.trim();
        final pwCheck = _pwCheck.text.trim();

        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        if (pw != pwCheck) {
          messenger.showSnackBar(
            const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
          );
          return;
        }

        final err = await auth.signUpAdmin(
          shopName: shop,
          email: email,
          password: pw,
        );

        if (err != null) {
          messenger.showSnackBar(SnackBar(content: Text(err)));
          return;
        }

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AdminOrderMScreen(
              adminUid: FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
          (route) => false,
        );
      },
      submitText: auth.loading ? '회원가입 중...' : '회원가입',
    );
  }
}
