

import 'package:get/get.dart';
import 'package:valuemate/res/routes/routes_name.dart';
import 'package:valuemate/view/auth/login.dart';
import 'package:valuemate/view/booking/property_form_screen.dart';
import 'package:valuemate/view/dashboard/dashboard_screen.dart';
import 'package:valuemate/view/splash.dart';
import 'package:valuemate/view/walk_through/walk_through.dart';


class AppRoutes {

  static appRoutes() => [
    GetPage(
      name: RouteName.splashScreen,
      page: () => SplashScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
    ) ,
    GetPage(
      name: RouteName.walk_through,
      page: () => WalkThroughScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
    ) ,
    GetPage(
      name: RouteName.loginView,
      page: () => LoginScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.downToUp ,
    ) ,
    GetPage(
      name: RouteName.dashboard,
      page: () => DashboardScreen() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.downToUp ,
    ) ,
    GetPage(
      name: RouteName.form,
      page: () => PropertyForm() ,
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.downToUp ,
    ) ,
    // GetPage(
    //   name: RouteName.loginView,
    //   page: () => LoginView() ,
    //   transitionDuration: Duration(milliseconds: 250),
    //   transition: Transition.leftToRightWithFade ,
    // ) ,
    // GetPage(
    //   name: RouteName.homeView,
    //   page: () => HomeView() ,
    //   transitionDuration: Duration(milliseconds: 250),
    //   transition: Transition.leftToRightWithFade ,
    // ) ,
  ];

}