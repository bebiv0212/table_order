import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:table_order/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loading = false;
  bool get loading => _loading;

  String? _shopName;
  String? get shopName => _shopName;

  bool get isLoggedIn => _auth.currentUser != null;

  // 회원가입
  Future<String?> signUpAdmin({
    required String shopName,
    required String email,
    required String password,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      final user = await _service.signUpAdmin(
        shopName: shopName,
        email: email,
        password: password,
      );

      final doc = await _db.collection('admins').doc(user!.uid).get();
      _shopName = doc.data()?['shopName'];

      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return _service.mapError(e);
    }
  }

  //관리자 로그인
  Future<String?> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;
      final adminRef = FirebaseFirestore.instance.collection('admins').doc(uid);
      final snap = await adminRef.get();

      if (!snap.exists) {
        final shopName = cred.user!.displayName ?? '내 매장';
        await adminRef.set({
          'uid': uid,
          'email': cred.user!.email ?? email.trim(),
          'shopName': shopName,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _shopName = shopName;
      } else {
        _shopName = snap.data()?['shopName'];
      }

      _loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return AuthService().mapError(e);
    }
  }
  // 현재 로그인된 관리자 비밀번호가 맞는지 확인하는 함수
  Future<bool> verifyCurrentPassword(String password) async {
    try {
      final user = _auth.currentUser;

      // 로그인 상태가 아니거나 이메일이 없다면 실패 처리
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,   // 🔥 현재 로그인된 계정 이메일
        password: password,   // 🔥 사용자가 입력한 비밀번호
      );

      await user.reauthenticateWithCredential(credential);
      return true; // 비밀번호 일치
    } catch (e) {
      debugPrint("verifyCurrentPassword Error: $e");
      return false; // 비밀번호 불일치 or 오류
    }
  }


  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    _shopName = null; // 캐시 초기화
    notifyListeners();
  }
}
