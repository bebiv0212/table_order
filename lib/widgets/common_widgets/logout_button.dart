import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/auth_provider.dart';
import 'package:table_order/screens/auth/select_screen.dart';
import 'package:table_order/screens/customer_screen/widget/password_dialog.dart';

class LogoutButton extends StatelessWidget {
  final bool requirePassword; // 🔥 고객 화면일 때만 true

  const LogoutButton({super.key, this.requirePassword = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: IconButton(
        icon: Icon(LucideIcons.logOut),
        onPressed: () async {
          // 고객 화면 → 비밀번호 확인 필요
          if (requirePassword) {
            final ok = await passwordDialog(context);

            if (ok != true) return; // 취소 시 종료
          }

          if (!context.mounted) return;

          final provider = context.read<AuthProvider>();

          // 공통 로그아웃
          await provider.signOut();

          if (!context.mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SelectScreen()),
            (route) => false,
          );
        },
      ),
    );
  }
}
