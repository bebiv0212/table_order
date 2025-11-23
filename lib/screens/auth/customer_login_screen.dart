import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';
import 'package:table_order/screens/customer_screen/customer_menu_screen.dart';

import '../../providers/auth_provider.dart' as my_auth;

class CustomerLoginScreen extends StatelessWidget {
  CustomerLoginScreen({super.key});

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _tableNum = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<my_auth.AuthProvider>();
    return LoginForm(
      mode: AppMode.customer,
      title: '고객 주문하기',
      subtitle: '관리자 정보와 테이블 번호를 입력하세요',
      icon: LucideIcons.shoppingBag,
      fields: [
        GreyTextField(
          controller: _email,
          label: '관리자 이메일',
          hint: 'admin@email.com',
          obscure: false,
        ),
        GreyTextField(
          controller: _password,
          label: '비밀번호',
          hint: '********',
          obscure: true,
        ),
        GreyTextField(
          controller: _tableNum,
          label: '테이블 번호',
          hint: '01, 02, 03...',
          obscure: false,
        ),
      ],
      onSubmit: () async {
        final email = _email.text.trim();
        final pw = _password.text.trim();
        final table = _tableNum.text.trim();

        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        if (email.isEmpty || pw.isEmpty || table.isEmpty) {
          messenger.showSnackBar(
            const SnackBar(content: Text('모든 항목을 입력해주세요.')),
          );
          return;
        }

        try {
          // Firebase 로그인
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: pw,
          );

          final uid = cred.user!.uid;
          final db = FirebaseFirestore.instance;

          // 관리자 확인
          final adminDoc = await db.collection('admins').doc(uid).get();
          if (!adminDoc.exists) {
            messenger.showSnackBar(
              const SnackBar(content: Text('관리자 계정이 아닙니다.')),
            );
            await FirebaseAuth.instance.signOut();
            return;
          }

          final shopName = adminDoc['shopName'] ?? '매장';

          // 테이블 문서 업서트
          final tableRef = db
              .collection('admins')
              .doc(uid)
              .collection('tables')
              .doc(table);

          await tableRef.set({
            'tableNumber': table,
            'status': 'idle',
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // 이동
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (_) => CustomerMenuScreen(
                adminUid: uid,
                shopName: shopName,
                tableNumber: table,
              ),
            ),
          );
        } on FirebaseAuthException catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text(e.message ?? '로그인 실패')),
          );
        }
      },
      submitText: auth.loading ? '로그인 중...' : '주문 시작하기',
    );
  }
}
