import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_order/models/menu_model.dart';
import 'package:table_order/services/menu_service.dart';

class MenuFormResult {
  final String name;
  final int price;
  final String category;
  final String description;
  final String imageUrl;
  final bool isAvailable;

  MenuFormResult({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.isAvailable,
  });
}

class MenuFormProvider extends ChangeNotifier {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  bool isAvailable = true;
  File? imageFile;

  void toggle(bool v) {
    isAvailable = v;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      notifyListeners();
    }
  }

  void removeImage() {
    imageFile = null;
    imageCtrl.clear();
    notifyListeners();
  }

  MenuFormResult? submit(BuildContext context) {
    final name = nameCtrl.text.trim();
    final priceText = priceCtrl.text.trim();

    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("메뉴명과 가격은 필수입니다.")));
      return null;
    }

    final price = int.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("가격은 숫자로 입력해주세요.")));
      return null;
    }

    return MenuFormResult(
      name: name,
      price: price,
      category: categoryCtrl.text.trim(),
      description: descCtrl.text.trim(),
      imageUrl: imageCtrl.text.trim(),
      isAvailable: isAvailable,
    );
  }

  final _service = MenuService();

  /// Firebase 저장 기능
  Future<bool> saveToFirebase({required String adminUid}) async {
    try {
      String imageUrl = imageCtrl.text.trim();

      if (imageFile != null) {
        final uploadedUrl = await _service.uploadImage(imageFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final menu = MenuModel(
        name: nameCtrl.text.trim(),
        price: int.parse(priceCtrl.text.trim()),
        category: categoryCtrl.text.trim(),
        description: descCtrl.text.trim(),
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );

      await _service.addMenu(adminUid, menu);
      return true;
    } catch (e) {
      debugPrint("Firebase Save Error: $e");
      return false;
    }
  }
}
