import 'package:flutter/material.dart';
import 'package:table_order/screens/auth/admin_login_screen.dart';
import 'package:table_order/screens/auth/customer_login_screen.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/rounded_rec_button.dart';

class ModeContainer extends StatelessWidget {
  const ModeContainer({
    super.key,
    required this.mode,
    required this.modeTitle,
    required this.description,
    required this.btnText,
    required this.icon,
  });

  final AppMode mode;
  final String modeTitle;
  final String description;
  final String btnText;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(mode);
    final bg = AppColors.bg(mode);

    return Container(
      width: 590,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(50),
              ),
              child: icon,
            ),
            Text(
              modeTitle,
              style: const TextStyle(
                fontSize: 30, //
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              description, //
              style: const TextStyle(fontSize: 20),
            ),
            Row(
              children: [
                Expanded(
                  child: RoundedRecButton(
                    text: btnText,
                    bgColor: primary, // AppColors.primary(mode)
                    fgColor: Colors.white,
                    onPressed: () {
                      if (mode == AppMode.customer) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerLoginScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AdminLoginScreen()),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
