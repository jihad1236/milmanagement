
import 'package:get/get.dart';
import 'package:milmanagement/core/controllers/theme_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<LogInController>(
    //       () => LogInController(),
    //   fenix: true,
    // );
    Get.put(ThemeController());
  }
}
