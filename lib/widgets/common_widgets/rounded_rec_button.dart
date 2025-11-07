import 'package:flutter/material.dart';

class RoundedRecButton extends StatelessWidget {
  const RoundedRecButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor,
    this.fgColor,
  });

  final String text;
  final VoidCallback onPressed;
  final Color? bgColor; // 배경색
  final Color? fgColor; // 글자색

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        textStyle: const TextStyle(fontSize: 18),
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: bgColor,
        foregroundColor: fgColor,
      ),
      onPressed: onPressed,
      child: Text(
        text, //
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
    );
  }
}
