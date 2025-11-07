import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/app_theme.dart';
import 'package:valuemate/app_translations.dart';
import 'package:valuemate/res/routes/routes.dart';
import 'package:valuemate/theme_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize(); // ✅ Initialize nb_utils first!

  // Get saved locale from storage
  String localeString = getStringAsync('locale');
  Locale? savedLocale;
  if (localeString.isNotEmpty && localeString.contains('_')) {
    final parts = localeString.split('_');
    savedLocale = Locale(parts[0], parts[1]);
  }

  Get.put(ThemeController()); // ✅ Then register controller

  runApp(MyApp(savedLocale: savedLocale));
}


class MyApp extends StatelessWidget {
  final Locale? savedLocale;
  const MyApp({super.key, this.savedLocale});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ValueMate',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeController.themeMode.value, // ✅ reactive theme
          locale: savedLocale ?? Get.deviceLocale,
          translations: AppTranslations(), // To be created
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
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
// Translations are provided by `lib/app_translations.dart`.

