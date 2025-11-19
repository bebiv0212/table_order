import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_order/models/menu_model.dart';
import 'package:table_order/services/menu_service.dart';

/// 폼에서 입력이 끝난 뒤, 결과를 넘길 때 쓰는 DTO(데이터 묶음) 클래스
class MenuFormResult {
  final String name; // 메뉴명
  final int price; // 가격
  final String category; // 카테고리 (메인, 음료 등)
  final String description; // 설명
  final String imageUrl; // 이미지 URL (선택)
  final bool isAvailable; // 판매 여부

  MenuFormResult({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.isAvailable,
  });
}

/// 메뉴 추가/수정 화면에서 사용하는 Provider
///   - TextEditingController 들을 가지고 있고
///   - 이미지 선택, 스위치 토글, Firebase 저장 등을 담당
class MenuFormProvider extends ChangeNotifier {
  /// 입력 폼 컨트롤러들
  final nameCtrl = TextEditingController(); // 메뉴 이름
  final priceCtrl = TextEditingController(); // 가격
  final categoryCtrl = TextEditingController(); // 카테고리
  final descCtrl = TextEditingController(); // 설명
  final imageCtrl = TextEditingController(); // (선택) 이미지 URL 직접 입력용

  /// 판매 가능 여부 스위치 값
  bool isAvailable = true;

  /// 갤러리에서 선택한 실제 이미지 파일 (Storage 업로드용)
  ///   - null이면 이미지 선택 안 했다는 뜻
  File? imageFile;

  /// 판매 가능 여부 토글 (스위치 onChanged에서 사용)
  void toggle(bool v) {
    isAvailable = v;
    notifyListeners(); // 화면에 반영
  }

  /// 저장/수정 버튼 클릭시 로딩 여부
  bool isSaving = false;

  /// 갤러리에서 이미지 1장 선택해서 imageFile에 저장
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      notifyListeners(); // 이미지 미리보기 위젯 리빌드
    }
  }

  /// 선택된 이미지 & 입력된 URL 제거
  void removeImage() {
    imageFile = null; // 로컬 선택 파일 제거
    imageCtrl.clear(); // URL 텍스트 필드도 비우기
    notifyListeners();
  }

  /// 폼 유효성 검사 + 결과 묶어서 반환
  /// - 에러면 SnackBar 보여주고 null 리턴
  MenuFormResult? submit(BuildContext context) {
    final name = nameCtrl.text.trim();
    final priceText = priceCtrl.text.trim();

    // 메뉴명 & 가격은 필수
    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("메뉴명과 가격은 필수입니다.")));
      return null;
    }

    // 가격 숫자 변환 체크
    final price = int.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("가격은 숫자로 입력해주세요.")));
      return null;
    }

    // 유효하면 결과 객체 생성해서 반환
    return MenuFormResult(
      name: name,
      price: price,
      category: categoryCtrl.text.trim(),
      description: descCtrl.text.trim(),
      imageUrl: imageCtrl.text.trim(),
      isAvailable: isAvailable,
    );
  }

  /// 실제 Firebase 관련 작업을 처리하는 서비스
  final _service = MenuService();

  /// Firebase 저장 기능 (새 메뉴 추가 + 기존 메뉴 수정 둘 다 처리)
  ///   - [adminUid] : 현재 관리자 uid (admins/{adminUid}/menus 아래에 저장)
  ///   - [oldMenu]  : 수정 모드일 때 넘기는 기존 메뉴. 추가 모드일 땐 null
  Future<bool> saveToFirebase({
    required String adminUid,
    MenuModel? oldMenu,
  }) async {
    try {
      isSaving = true;
      notifyListeners(); // 로딩 시작

      String imageUrl = imageCtrl.text.trim();

      if (imageFile != null) {
        final uploadedUrl = await _service.uploadImage(imageFile!);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      final newData = MenuModel(
        id: oldMenu?.id,
        name: nameCtrl.text.trim(),
        price: int.parse(priceCtrl.text.trim()),
        category: categoryCtrl.text.trim(),
        description: descCtrl.text.trim(),
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );

      if (oldMenu == null) {
        await _service.addMenu(adminUid, newData);
      } else {
        await _service.updateMenu(adminUid, oldMenu.id!, newData);

        if (imageFile != null && oldMenu.imageUrl.isNotEmpty) {
          await _service.deleteImageByUrl(oldMenu.imageUrl);
        }
      }

      isSaving = false;
      notifyListeners(); // 로딩 종료
      return true;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      debugPrint("Firebase Save Error: $e");
      return false;
    }
  }

  /// 수정 모드 진입 시, 기존 메뉴 데이터를 폼에 채워넣기
  void setMenuForEdit(MenuModel menu) {
    nameCtrl.text = menu.name;
    priceCtrl.text = menu.price.toString();
    categoryCtrl.text = menu.category;
    descCtrl.text = menu.description;
    imageCtrl.text = menu.imageUrl; // 기존 이미지 URL 그대로 입력칸에 세팅
    isAvailable = menu.isAvailable;

    notifyListeners(); // 화면 갱신
  }
}
