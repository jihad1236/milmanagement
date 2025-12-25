import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeController();

  /// Tracks whether dark mode is currently enabled.
  final RxBool isDarkMode = false.obs;

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = platformBrightness == Brightness.dark;
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(themeMode);
  }
}
