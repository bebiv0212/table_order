import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmptyScreen extends StatelessWidget {
  final String message;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;

  const EmptyScreen({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onPressed,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFEFEFF2),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.info, size: 40, color: Colors.grey),
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
