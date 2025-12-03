import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_order/providers/auth_provider.dart';
import 'package:table_order/theme/app_colors.dart';

/// 관리자 비밀번호 확인 다이얼로그
Future<bool?> passwordDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      bool isLoading = false;
      String? errorText;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 480, // 다이얼로그 가로 최대 폭
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// 상단 제목 + X버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '관리자 비밀번호 확인',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 22),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    /// 설명 텍스트
                    Text(
                      '나가기 위해 관리자 비밀번호를 입력해주세요.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),

                    SizedBox(height: 20), // 24 → 20로 약간 줄임
                    /// 비밀번호 입력창
                    TextField(
                      controller: controller,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14, // 16 → 14로 살짝 줄임
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFD9D9D9),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.customerPrimary,
                            width: 2,
                          ),
                        ),
                        errorText: errorText,
                      ),
                    ),

                    SizedBox(height: 24), // 28 → 24
                    /// 버튼 영역
                    Row(
                      children: [
                        /// 취소 버튼(회색)
                        Expanded(
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () => Navigator.of(dialogContext).pop(false),
                            child: Container(
                              height: 46, // 50 → 46
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF444444),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12),

                        /// 확인 버튼(주황색)
                        Expanded(
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () async {
                                    final password = controller.text.trim();

                                    if (password.isEmpty) {
                                      setState(() {
                                        errorText = '비밀번호를 입력해주세요.';
                                      });
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                      errorText = null;
                                    });

                                    final auth = dialogContext
                                        .read<AuthProvider>();
                                    final ok = await auth.verifyCurrentPassword(
                                      password,
                                    );

                                    if (!context.mounted) return;

                                    if (ok) {
                                      Navigator.of(dialogContext).pop(true);
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                        errorText = '비밀번호가 올바르지 않습니다.';
                                      });
                                    }
                                  },
                            child: Container(
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.customerPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '확인',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
