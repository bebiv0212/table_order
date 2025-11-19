import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_order/theme/app_colors.dart';
import 'package:table_order/widgets/common_widgets/grey_text_field.dart';
import 'editable_image_picker_box.dart';
import 'package:table_order/providers/menu_form_provider.dart';

class MenuFormPage extends StatelessWidget {
  final bool isEdit;
  final String adminUid;

  const MenuFormPage({super.key, this.isEdit = false, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MenuFormProvider>();

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 12),
                ],
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

                    SizedBox(width: 24),

                    // 오른쪽: 텍스트 필드 + 스위치 + 버튼
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: GreyTextField(
                                label: '메뉴명',
                                hint: '김치찌개',
                                obscure: false,
                                controller: prov.nameCtrl,
                              ),
                            ),

                            GreyTextField(
                              label: '가격',
                              hint: '9000',
                              obscure: false,
                              controller: prov.priceCtrl,
                              keyboardType: TextInputType.number,
                            ),

                            GreyTextField(
                              label: '카테고리',
                              hint: '메인, 음료, 디저트 등',
                              obscure: false,
                              controller: prov.categoryCtrl,
                            ),

                            GreyTextField(
                              label: '설명 (선택)',
                              hint: '메뉴 설명',
                              obscure: false,
                              controller: prov.descCtrl,
                              maxLines: 4,
                            ),

                            Row(
                              children: [
                                CupertinoSwitch(
                                  value: prov.isAvailable,
                                  onChanged: prov.toggle,
                                  activeTrackColor: AppColors.adminPrimary,
                                  inactiveTrackColor: Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text("판매 가능"),
                              ],
                            ),

                            // 저장 버튼
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final result = prov.submit(context);
                                    if (result != null) {
                                      // 🔥 Firebase 저장 실행
                                      final success = await prov.saveToFirebase(
                                        adminUid: adminUid,
                                      );

                                      if (success) {
                                        Navigator.pop(context, result);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("저장 실패! 다시 시도해주세요."),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    LucideIcons.save,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isEdit ? "수정" : "추가",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
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
}
