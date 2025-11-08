import 'package:flutter/material.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/rounded_rec_button.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fields,
    required this.onSubmit,
    required this.submitText,
    this.hintBox,
  });

  final AppMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> fields; // 텍스트필드 묶음
  final VoidCallback onSubmit;
  final String submitText;
  final Widget? hintBox; // 테스트 계정 안내 같은 박스

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(mode);
    final bg = AppColors.bg(mode);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(icon, size: 50, color: primary),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                ...fields,
                if (hintBox != null) hintBox!,
                SizedBox(
                  width: double.infinity,
                  child: RoundedRecButton(
                    text: submitText,
                    onPressed: onSubmit,
                    fgColor: Colors.white,
                    bgColor: primary, // 모드별 컬러 버튼
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
