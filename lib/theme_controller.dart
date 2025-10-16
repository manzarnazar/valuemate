import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class ThemeController extends GetxController {
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void loadTheme() {
  int index = getIntAsync("theme_mode_index", defaultValue: 1);
  switch (index) {
    case 0:
      themeMode.value = ThemeMode.light;
      break;
    case 1:
      themeMode.value = ThemeMode.dark;
      break;
    case 2:
      themeMode.value = ThemeMode.system;
      break;
  }
}


  void setThemeMode(int index) {
    setValue("theme_mode_index", index);
    loadTheme(); // update theme
  }

  void setTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
