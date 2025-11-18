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

  const MenuFormPage({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MenuFormProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: Text(
          isEdit ? "메뉴 수정" : "메뉴 추가",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                isEdit ? "메뉴 정보를 수정하세요." : "새로운 메뉴를 추가하세요.",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adminPrimary,
                ),
              ),
              Row(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 왼쪽 — 이미지 영역
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

                  // 📌 오른쪽 — 입력 필드 영역
                  Expanded(
                    flex: 5,
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton.icon(
                              onPressed: () {
                                final result = prov.submit(context);
                                if (result != null) {
                                  Navigator.pop(context, result);
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
