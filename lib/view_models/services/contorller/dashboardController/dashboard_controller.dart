import 'package:get/get.dart';

class DashboardController extends GetxController {
  int currentIndex = 0;

  void setIndex(int index) {
    currentIndex = index;
    update();
  }

  @override
  void onInit() {
    // Read passed index (if any)
    if (Get.arguments != null && Get.arguments is int) {
      currentIndex = Get.arguments;
    }
    super.onInit();
  }
}
