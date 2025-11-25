import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_order/theme/app_colors.dart';

class AdminPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onBack;

  const AdminPageAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onPrimaryAction,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      toolbarHeight: 80,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          Text(subtitle, style: TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
      actions: [
        if (primaryActionLabel != null && primaryActionIcon != null)
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: onPrimaryAction,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.adminPrimary, // 🔥 색상 통일
              ),
              icon: Icon(primaryActionIcon, size: 18, color: Colors.white),
              label: Text(
                primaryActionLabel!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
