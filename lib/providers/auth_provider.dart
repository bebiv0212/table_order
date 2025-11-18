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

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    _shopName = null; // 캐시 초기화
    notifyListeners();
  }
}
