import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppbarActionBtn extends StatelessWidget {
  const AppbarActionBtn({super.key, required this.icon, required this.title});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black, size: 18),
      label: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600, //
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
