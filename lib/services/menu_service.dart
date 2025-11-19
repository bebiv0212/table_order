import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:table_order/models/menu_model.dart';

/// 🔧 메뉴 관련 Firebase 작업 전담 서비스
///   - Storage: 메뉴 이미지 업로드 / 삭제
///   - Firestore: 메뉴 CRUD (조회, 추가, 수정, 삭제)
class MenuService {
  /// Firebase Storage 인스턴스 (사진 파일 저장소)
  final storage = FirebaseStorage.instance;

  /// Cloud Firestore 인스턴스 (메뉴 정보 문서 저장소)
  final firestore = FirebaseFirestore.instance;

  /// 📤 Storage에 이미지 업로드 후 다운로드 URL 반환
  ///  - [file] : 로컬에서 선택한 이미지 파일
  ///  - return : 업로드된 이미지의 다운로드 URL (실패 시 null)
  Future<String?> uploadImage(File file) async {
    try {
      // 파일 이름을 현재 시간 기반으로 생성 → 중복 방지
      final fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Storage 경로: menu_images/파일명
      final ref = storage.ref().child("menu_images/$fileName");

      // 실제 파일 업로드
      await ref.putFile(file);

      // 업로드가 성공하면 다운로드 가능한 URL 반환
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      return null;
    }
  }

  /// 🗑 이미지 URL로 Storage 파일 삭제
  ///   - [imageUrl] : Storage에 업로드된 파일의 공용 URL
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      // URL에서 바로 참조(ref) 객체 가져오기
      final ref = storage.refFromURL(imageUrl);

      // 해당 파일 삭제
      await ref.delete();
    } catch (e) {
      // 파일이 이미 없거나 권한 오류 등 → 앱 죽지 않게 그냥 로그만
      debugPrint("🔥 Storage Delete Error: $e");
    }
  }

  /// 📚 메뉴 리스트 조회
  ///   - [adminUid] : 해당 점주의 문서 ID
  ///   - return     : MenuModel 리스트
  Future<List<MenuModel>> getMenus(String adminUid) async {
    // admins/{adminUid}/menus 컬렉션 전체 조회
    final snapshot = await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .get();

    // 각 문서를 MenuModel로 변환해서 리스트로 반환
    return snapshot.docs
        .map((doc) => MenuModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// ➕ 메뉴 추가 (신규 생성)
  ///   - [adminUid] : 점주 ID
  ///   - [menu]     : 저장할 메뉴 데이터
  Future<void> addMenu(String adminUid, MenuModel menu) async {
    await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .add(menu.toMap()); // Firestore 문서로 변환해서 추가
  }

  /// ✏ 메뉴 수정 (기존 문서 업데이트)
  ///   - [adminUid] : 점주 ID
  ///   - [menuId]   : 수정할 메뉴 문서 ID
  ///   - [menu]     : 변경된 데이터
  Future<void> updateMenu(
    String adminUid,
    String menuId,
    MenuModel menu,
  ) async {
    await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .doc(menuId)
        .update(menu.toMap()); // 해당 문서에 필드 업데이트
  }

  /// 🗑 메뉴 삭제 + Storage 이미지 삭제까지 같이 처리
  ///   - [adminUid] : 점주 ID
  ///   - [menuId]   : 삭제할 메뉴 문서 ID
  ///   - [imageUrl] : 해당 메뉴가 사용하던 이미지 URL (있다면 Storage도 삭제)
  Future<void> deleteMenu(
    String adminUid,
    String menuId,
    String imageUrl,
  ) async {
    // 1) Firestore 문서 삭제
    await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .doc(menuId)
        .delete();

    // 2) Storage 이미지 삭제 (URL이 비어있지 않을 때만)
    if (imageUrl.isNotEmpty) {
      await deleteImageByUrl(imageUrl);
    }
  }

  /// 🔹 판매 여부(isAvailable)만 업데이트
  Future<void> updateAvailability(
    String adminUid,
    String menuId,
    bool isAvailable,
  ) async {
    await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .doc(menuId)
        .update({'isAvailable': isAvailable});
  }
}
