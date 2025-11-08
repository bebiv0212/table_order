import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── (기존) 회원가입 메서드는 그대로 ──
  Future<User?> signUpAdmin({
    required String shopName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(shopName);
    await _db.collection('admins').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': email.trim(),
      'shopName': shopName,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred.user;
  }

  // ✅ (신규) 관리자 로그인
  Future<User?> signInAdmin({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  // (기존) 에러 매핑 그대로 사용
  String mapError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return '가입되지 않은 이메일입니다.';
        case 'wrong-password':
          return '비밀번호가 올바르지 않아요.';
        case 'invalid-email':
          return '이메일 형식이 올바르지 않아요.';
        case 'user-disabled':
          return '비활성화된 계정입니다.';
        default:
          return '로그인에 실패했어요. (${e.code})';
      }
    }
    return '알 수 없는 오류가 발생했어요.';
  }
}
