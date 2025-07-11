
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/res/colors/colors.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData lightTheme({Color? color}) => ThemeData(
    useMaterial3: true,
    primarySwatch: createMaterialColor(color ?? primaryColor),
    primaryColor: color ?? primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: color ?? primaryColor, outlineVariant: borderColor),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.inter().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
    iconTheme: IconThemeData(color: const Color.fromARGB(255, 73, 79, 84)),

    listTileTheme: ListTileThemeData(
        iconColor: borderColor,
        titleTextStyle: boldTextStyle(color: black),
        subtitleTextStyle: secondaryTextStyle()
    ),
    textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          headlineSmall: TextStyle(color: white),
          headlineMedium: TextStyle(color: white),
          bodyMedium: TextStyle(color: white),
          bodySmall: TextStyle(color: white),
        )
    ),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: borderColor,
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
      backgroundColor: Colors.white,
    ),
    cardColor: cardColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: color ?? primaryColor),
    appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: secondaryTextStyle(size: 22,color: white),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light)),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: dialogShape(),
    ),
    navigationBarTheme: NavigationBarThemeData(labelTextStyle: WidgetStateProperty.all(primaryTextStyle(size: 10))),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData darkTheme({Color? color}) => ThemeData(
    useMaterial3: true,
    primarySwatch: createMaterialColor(color ?? primaryColor),
    primaryColor: color ?? primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: color ?? primaryColor, outlineVariant: borderColor),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: secondaryTextStyle(size: 22,color: white),
      systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    ),
    scaffoldBackgroundColor: scaffoldColorDark,
    fontFamily: GoogleFonts.inter().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
    iconTheme: IconThemeData(color: Colors.white),
    listTileTheme: ListTileThemeData(
        iconColor: Colors.white,
        titleTextStyle: boldTextStyle(color: white),
        subtitleTextStyle: secondaryTextStyle()
    ),
    textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          headlineSmall: TextStyle(color: white),
          headlineMedium: TextStyle(color: white),
          bodyMedium: TextStyle(color: white),
          bodySmall: TextStyle(color: white),
          bodyLarge: TextStyle(color: white),
          headlineLarge: TextStyle(color: white),

        )
    ),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
      backgroundColor: scaffoldSecondaryDark,
    ),
    dividerColor: dividerDarkColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: color ?? primaryColor),
    cardColor: scaffoldSecondaryDark,
    dialogTheme: DialogTheme(
      backgroundColor: scaffoldSecondaryDark,
      surfaceTintColor: Colors.transparent,
      shape: dialogShape(),
    ),
    navigationBarTheme: NavigationBarThemeData(labelTextStyle: WidgetStateProperty.all(primaryTextStyle(size: 10, color: Colors.white))),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
