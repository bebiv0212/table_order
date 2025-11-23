import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/models/menu_model.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';
import 'editable_image_picker_box.dart';
import 'package:table_order/providers/menu_form_provider.dart';

class MenuFormPage extends StatelessWidget {
  final bool isEdit;
  final String adminUid;
  final MenuModel? menu;

  const MenuFormPage({
    super.key,
    this.isEdit = false,
    required this.adminUid,
    this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MenuFormProvider>();

    if (isEdit && menu != null && prov.nameCtrl.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        prov.setMenuForEdit(menu!);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 24),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 상단 뒤로가기 + 제목 영역
              IconButton(
                icon: Icon(LucideIcons.arrowLeft),
                onPressed: () => Navigator.pop(context),
              ),

              SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    isEdit ? "메뉴 정보를 수정하세요." : "새로운 메뉴를 추가하세요.",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adminPrimary,
                    ),
                  ),
                ),
              ),

              // 📐 메인 레이아웃 (이미지 + 폼)
              Expanded(
                child: Row(
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 왼쪽: 이미지 선택 영역
                    Expanded(
                      flex: 5,
                      child: EditableImagePickerBox(
                        imageFile: prov.imageFile,
                        imageUrl: prov.imageCtrl.text.isEmpty
                            ? null
                            : prov.imageCtrl.text,
                        onPickImage: prov.pickImage,
                        onRemoveImage: prov.removeImage,
                      ),
                    ),

                    // 오른쪽: 텍스트 필드 + 스위치 + 버튼
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            GreyTextField(
                              label: '*메뉴명',
                              hint: '김치찌개',
                              obscure: false,
                              controller: prov.nameCtrl,
                            ),

                            GreyTextField(
                              label: '*가격',
                              hint: '9000',
                              obscure: false,
                              controller: prov.priceCtrl,
                              keyboardType: TextInputType.number,
                            ),

                            GreyTextField(
                              label: '*카테고리',
                              hint: '메인, 음료, 디저트 등',
                              obscure: false,
                              controller: prov.categoryCtrl,
                            ),

                            GreyTextField(
                              label: '설명 (선택)',
                              hint: '메뉴 설명',
                              obscure: false,
                              controller: prov.descCtrl,
                              maxLines: 6,
                            ),

                            // 저장/수정 버튼
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: TextButton.icon(
                                      onPressed: prov.isSaving
                                          ? null
                                          : () async {
                                              final result = prov.submit(
                                                context,
                                              );
                                              if (result == null) return;

                                              // ❗ await 전에 context 잡아두기
                                              final navigator = Navigator.of(
                                                context,
                                              );

                                              final success = await prov
                                                  .saveToFirebase(
                                                    adminUid: adminUid,
                                                    oldMenu: isEdit
                                                        ? menu
                                                        : null,
                                                  );
                                              if (success) {
                                                navigator.pop(
                                                  true,
                                                ); // ✔ async gap 뒤 context 직접 사용 X
                                              }
                                            },
                                      icon: prov.isSaving
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              LucideIcons.save,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                      label: Text(
                                        prov.isSaving
                                            ? (isEdit ? "수정 중..." : "추가 중...")
                                            : (isEdit ? "수정" : "추가"),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: AppColors.adminPrimary,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _warningText(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text _warningText() {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 15),
        children: [
          TextSpan(
            text: '( ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: ' ) ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: '표시는 ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: '필수입력 ',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '사항입니다.',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
