import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:table_order/firebase_options.dart';
import 'package:table_order/providers/auth_provider.dart';
import 'package:table_order/providers/cart_provider.dart';
import 'package:table_order/providers/category_provider.dart';
import 'package:table_order/providers/menu_count_provider.dart';
import 'package:table_order/screens/select_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko_KR', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, //
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MenuCountProvider()),
      ],
      child: MaterialApp(
        title: 'Table Order',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        // ✅ 첫 화면을 SelectScreen으로 지정
        home: SelectScreen(),
      ),
    );
  }
}
