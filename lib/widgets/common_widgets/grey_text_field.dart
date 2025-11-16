import 'package:flutter/material.dart';

class GreyTextField extends StatelessWidget {
  const GreyTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.obscure,
    this.controller,
  });

  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
