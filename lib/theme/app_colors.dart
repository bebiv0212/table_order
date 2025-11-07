import 'package:flutter/material.dart';

enum AppMode { customer, admin }

class AppColors {
  // 고객
  static const customerPrimary = Color(0xFFFF6A00);
  static const customerBg = Color(0xFFFFF3E9);

  // 관리자
  static const adminPrimary = Color(0xFF2F80ED);
  static const adminBg = Color(0xFFEFF5FF);

  // 모드별 주요 색 뽑기
  static Color primary(AppMode m) =>
      m == AppMode.customer ? customerPrimary : adminPrimary;

  static Color bg(AppMode m) => m == AppMode.customer ? customerBg : adminBg;
}
