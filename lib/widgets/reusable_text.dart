import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

class ReusableText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double fontSize;
  final double? letterSpacing;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final bool textOverflow;
  final String fontFamily;
  const ReusableText({
    super.key,
    required this.text,
    this.textColor = AppColors.textPrimary,
    this.fontSize = 9,
    this.textOverflow = false,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.center,
    this.letterSpacing,
    this.fontFamily = 'PlusJakartaSans',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      overflow: textOverflow ? TextOverflow.ellipsis : TextOverflow.visible,
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        letterSpacing: letterSpacing,
        color: textColor,
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
      ),
    );
  }
}
