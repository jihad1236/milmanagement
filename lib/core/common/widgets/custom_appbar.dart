
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:milmanagement/core/utils/theme_globals.dart';
import '../../utils/constants/colors.dart';
import '../../../core/common/styles/global_text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool translateTitle;
  final bool showBack;
  final VoidCallback? onBackTap;
  final bool showSearch;
  final VoidCallback? onSearchTap;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.translateTitle = false,
    this.showBack = false,
    this.onBackTap,
    this.showSearch = false,
    this.onSearchTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      return Container(
        height: preferredSize.height,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDarkMode ? AppColors.deepForest : AppColors.white),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: isDarkMode
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.accentGold.withValues(alpha: .4),
                  ),
                )
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  // Back Button or placeholder (fixed width for symmetry)
                  SizedBox(
                    width: 40.w,
                    child: showBack
                        ? GestureDetector(
                            onTap: onBackTap ?? () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20.w,
                              color: isDarkMode
                                  ? AppColors.white
                                  : AppColors.deepForest,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Title — centered with Expanded
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.white
                            : AppColors.deepForest,
                      ),
                    ),
                  ),

                  // Search icon or placeholder (fixed width for symmetry)
                  SizedBox(
                    width: 40.w,
                    child: showSearch
                        ? GestureDetector(
                            onTap: onSearchTap,
                            child: Icon(
                              Icons.search,
                              size: 22.w,
                              color: AppColors.deepForest,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      );
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
