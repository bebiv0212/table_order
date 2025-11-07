import 'package:flutter/material.dart';
import 'package:table_order/screens/select_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Order',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // ✅ 첫 화면을 SelectScreen으로 지정
      home: SelectScreen(),
    );
  }
}
