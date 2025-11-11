import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/screens/auth/widget/login_form.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';
import 'package:table_order/screens/customer_screen/customer_menu_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _tableNum = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
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
          hint: '예: 01, 02, 03...',
          obscure: false,
        ),
      ],
      onSubmit: () async {
        final email = _email.text.trim();
        final pw = _password.text.trim();
        final table = _tableNum.text.trim();

        if (email.isEmpty || pw.isEmpty || table.isEmpty) {
          if (!mounted) return; // ✅ context 사용 전 검사
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
          return;
        }

        setState(() => _loading = true);
        try {
          // 1️⃣ Firebase 로그인
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: pw,
          );

          if (!mounted) return; // ✅ context 안전 체크
          final uid = cred.user!.uid;
          final db = FirebaseFirestore.instance;

          // 2️⃣ 관리자 확인
          final adminDoc = await db.collection('admins').doc(uid).get();
          if (!mounted) return; // ✅ context 사용 전 검사
          if (!adminDoc.exists) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('관리자 계정이 아닙니다.')));
            await FirebaseAuth.instance.signOut();
            setState(() => _loading = false);
            return;
          }

          final shopName = adminDoc.data()?['shopName'] ?? '매장';

          // 3️⃣ 테이블 문서 업서트
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

          if (!mounted) return; // ✅ context 안전
          // 4️⃣ 고객 메뉴 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerMenuScreen(
                adminUid: uid,
                shopName: shopName,
                tableNumber: table,
              ),
            ),
          );
        } on FirebaseAuthException catch (e) {
          if (!mounted) return; // ✅ context 검사
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message ?? '로그인 실패')));
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      },
      submitText: _loading ? '로그인 중...' : '주문 시작하기',
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _tableNum.dispose();
    super.dispose();
  }
}
