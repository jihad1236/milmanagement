
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:milmanagement/core/controllers/theme_controller.dart';
import '../../utils/constants/colors.dart';
import '../styles/global_text_style.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.fontWeight,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.isOutlined = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.shadow,
  });

  /// Button text
  final String text;

  /// Action
  final VoidCallback? onTap;

  /// Optional icon
  final Widget? icon;

  /// Colors
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  /// Styles
  final double? textSize;
  final FontWeight? fontWeight;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;
  final bool isLoading;
  final bool isDisabled;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDarkMode = themeController.isDarkMode.value;
    final Color bgColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ??
              (isDarkMode ? AppColors.mutedOlive : AppColors.dullMossGreen));

    final Color txtColor = isOutlined
        ? (textColor ?? AppColors.lightLimestoneTan)
        : (textColor ?? Colors.white);

    final Color brColor = isOutlined
        ? (borderColor ?? AppColors.lightLimestoneTan)
        : (borderColor ?? Colors.transparent);

    return Opacity(
      opacity: isDisabled ? 0.6 : 1,
      child: GestureDetector(
        onTap: isDisabled || isLoading ? null : onTap,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? 50.h,
          // padding: padding ?? EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            border: Border.all(color: brColor, width: 1),
            boxShadow: shadow,
          ),
          child: Center(
            child: isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 18.sp,
                        width: 18.sp,
                        child: CircularProgressIndicator(
                          color: txtColor,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                            fontSize: 13.sp,
                            fontWeight: fontWeight ?? FontWeight.w500,
                            color: txtColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                      Flexible(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                            fontSize: 13.sp,
                            fontWeight: fontWeight ?? FontWeight.w500,
                            color: txtColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
