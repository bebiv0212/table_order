import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:table_order/models/menu_model.dart';

class MenuService {
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;

  /// 사진을 Firebase Storage에 업로드 후 URL 리턴
  Future<String?> uploadImage(File file) async {
    try {
      final fileName =
          "menu_${DateTime.now().millisecondsSinceEpoch}.jpg"; // 고유한 이름

      final ref = storage.ref().child("menu_images/$fileName");
      await ref.putFile(file);

      return await ref.getDownloadURL(); // 🔥 실제 이미지 URL
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      return null;
    }
  }

  /// Firestore에 메뉴 데이터 저장
  Future<void> addMenu(String adminUid, MenuModel menu) async {
    await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .add(menu.toMap());
  }

  //메뉴 불러오기
  Future<List<MenuModel>> getMenus(String adminUid) async {
    final snapshot = await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .get();

    return snapshot.docs
        .map((doc) => MenuModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  //메뉴 삭제
  Future<void> deleteMenu(String adminUid, String menuId) async {
    await firestore
        .collection("admins")
        .doc(adminUid)
        .collection("menus")
        .doc(menuId)
        .delete();
  }
}
