import 'dart:io';
import 'package:flutter/material.dart';

class EditableImagePickerBox extends StatelessWidget {
  final File? imageFile; // 이미 선택한 로컬 파일
  final String? imageUrl; // 기존 Firebase 이미지 URL
  final VoidCallback onPickImage; // 이미지 선택(갤러리 열기)
  final VoidCallback? onRemoveImage; // 이미지 삭제(수정 모드 전용)

  const EditableImagePickerBox({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onPickImage,
    this.onRemoveImage,
  });

  bool get hasImage =>
      imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: 500,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.hardEdge,
        child: hasImage ? _buildPreview() : _buildEmptyBox(),
      ),
    );
  }

  // 📌 이미지 미리보기 + 삭제 버튼
  Widget _buildPreview() {
    return Stack(
      children: [
        Positioned.fill(
          child: imageFile != null
              ? Image.file(imageFile!, fit: BoxFit.cover)
              : Image.network(imageUrl!, fit: BoxFit.cover),
        ),

        // 삭제 버튼
        if (onRemoveImage != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemoveImage,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // 📌 처음 추가할 때 UI
  Widget _buildEmptyBox() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 36,
            color: Colors.black54,
          ),
          SizedBox(height: 4),
          Text(
            "*사진",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
