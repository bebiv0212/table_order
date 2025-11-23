import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewTagService {
  final String adminUid;
  ReviewTagService(this.adminUid);

  CollectionReference<Map<String, dynamic>> get _tagRef => FirebaseFirestore
      .instance
      .collection('admins')
      .doc(adminUid)
      .collection('reviewTags');

  /// 🔥 태그 추가
  Future<String?> addTag(String name) async {
    if (name.trim().isEmpty) return "태그 이름을 입력해주세요.";

    final dup = await _tagRef.where('name', isEqualTo: name).get();
    if (dup.docs.isNotEmpty) return "이미 존재하는 태그입니다.";

    await _tagRef.add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return null;
  }

  /// ❌ 태그 삭제
  Future<void> deleteTag(String tagId) async {
    await _tagRef.doc(tagId).delete();
  }

  /// 🔵 태그 스트림 (UI에서 StreamBuilder로 사용)
  Stream<QuerySnapshot<Map<String, dynamic>>> getTagStream() {
    return _tagRef.orderBy("createdAt").snapshots();
  }
}
