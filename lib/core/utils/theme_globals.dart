
import 'package:get/get.dart';
import 'package:milmanagement/core/controllers/theme_controller.dart';

/// Shared accessors for the theme controller and dark-mode flag.
final ThemeController themeController = Get.isRegistered<ThemeController>()
    ? Get.find<ThemeController>()
    : Get.put(ThemeController(), permanent: true);

bool get isDark => themeController.isDarkMode.value;
