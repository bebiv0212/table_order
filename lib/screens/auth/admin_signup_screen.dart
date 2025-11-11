import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/auth_provider.dart';
import 'package:table_order/screens/admin_screen/admin_order_m_screen.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _shopController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mode = AppMode.admin;

    return LoginForm(
      mode: mode,
      title: '관리자 회원가입',
      subtitle: '새로운 매장을 등록하세요',
      icon: LucideIcons.userPlus,
      fields: [
        GreyTextField(
          controller: _shopController,
          label: '가게 이름',
          hint: '우리 식당',
          obscure: false,
        ),
        GreyTextField(
          controller: _emailController,
          label: '관리자 이메일',
          hint: 'admin@email.com',
          obscure: false,
        ),
        GreyTextField(
          controller: _pwController,
          label: '비밀번호(6자리 이상)',
          hint: '********',
          obscure: true,
        ),
        GreyTextField(
          controller: _pwCheckController,
          label: '비밀번호 확인',
          hint: '********',
          obscure: true,
        ),
      ],
      onSubmit: () async {
        final shop = _shopController.text.trim();
        final email = _emailController.text.trim();
        final pw = _pwController.text.trim();
        final pwCheck = _pwCheckController.text.trim();

        if (pw != pwCheck) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
          return;
        }

        final err = await auth.signUpAdmin(
          shopName: shop,
          email: email,
          password: pw,
        );

        if (!context.mounted) return;

        if (err != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminOrderMScreen(shopName: auth.shopName ?? shop),
            ),
            (route) => false,
          );
        }
      },
      submitText: auth.loading ? '회원가입 중...' : '회원가입',
    );
  }

  @override
  void dispose() {
    _shopController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    super.dispose();
  }
}
