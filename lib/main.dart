import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/app_theme.dart';
import 'package:valuemate/res/routes/routes.dart';
import 'package:valuemate/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize(); // <-- this is critical for nb_utils

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController());
      }),
      debugShowCheckedModeBanner: false,
      title: 'ValueMate',
      theme: AppTheme.lightTheme(), // Using light theme
      darkTheme: AppTheme.darkTheme(), // Using dark theme
      // themeMode: ThemeMode.light, // Set default theme mode to light
      locale: const Locale('en', 'US'),
      getPages: AppRoutes.appRoutes(),
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
        );
      },
    );
  }
}