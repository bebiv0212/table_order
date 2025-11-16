import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StaffCallDialog extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const StaffCallDialog({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "직원 호출",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "필요하신 서비스를 선택해주세요.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: [
                _gridItem(
                  Icon(LucideIcons.droplets, color: Colors.blue, size: 22),
                  "물",
                  "water",
                ),
                _gridItem(
                  Icon(LucideIcons.utensils, color: Colors.grey, size: 22),
                  "수저/포크",
                  "fork",
                ),
                _gridItem(
                  Icon(LucideIcons.stickyNote, color: Colors.grey, size: 22),
                  "휴지/물티슈",
                  "tissue",
                ),
                _gridItem(
                  Icon(LucideIcons.torus, color: Colors.orange, size: 22),
                  "앞접시",
                  "plate",
                ),
                _gridItem(
                  Icon(LucideIcons.shirt, color: Colors.green, size: 22),
                  "앞치마",
                  "apron",
                ),
                _gridItem(
                  Icon(LucideIcons.bellRing, color: Colors.red, size: 22),
                  "직원호출",
                  "staff",
                ),
              ],
            ),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "취소",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridItem(Icon icon, String text, String key) {
    return GestureDetector(
      onTap: () => onSelect(key),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
