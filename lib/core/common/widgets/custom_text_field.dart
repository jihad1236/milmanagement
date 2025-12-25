import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/colors.dart';
import '../../utils/theme_globals.dart';
import '../styles/global_text_style.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Color? fillColor;
  final Color? borderColor;
  final Color? hintColor;
  final Color? textColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.hintColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool darkTheme = isDark;
    final Color effectiveFillColor =
        fillColor ??
        (darkTheme
            ? AppColors.deepForest.withValues(alpha: 0.85)
            : Colors.white);
    final Color effectiveBorderColor =
        borderColor ??
        (darkTheme
            ? AppColors.border.withValues(alpha: 0.4)
            : Colors.grey.shade300);
    final Color effectiveHintColor =
        hintColor ?? (darkTheme ? Colors.white70 : Colors.grey.shade600);
    final Color effectiveTextColor =
        textColor ?? (darkTheme ? Colors.white : AppColors.textPrimary);
    final Color labelColor = darkTheme
        ? AppColors.accentGold
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          readOnly: readOnly,
          validator: validator,
          onChanged: onChanged,
          style: getTextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: effectiveTextColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: getTextStyle(
              fontSize: 12.sp,
              color: effectiveHintColor,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: effectiveFillColor,
            prefixIcon: prefixIcon,
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                  )
                : suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 14.w,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: effectiveBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: AppColors.accentGold,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
