import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/app_theme.dart';
import 'package:valuemate/res/routes/routes.dart';
import 'package:valuemate/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize(); // ✅ Initialize nb_utils first!

  Get.put(ThemeController()); // ✅ Then register controller

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ValueMate',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeController.themeMode.value, // ✅ reactive theme
          locale: const Locale('en', 'US'),
          getPages: AppRoutes.appRoutes(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ));
  }
}
