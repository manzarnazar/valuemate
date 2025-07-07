
import 'package:get/get.dart';
import 'package:valuemate/res/routes/routes_name.dart';
import 'package:valuemate/view_models/services/contorller/auth/user_prefrence_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashServices {

  UserPreference userPreference = UserPreference();


Future<String> checkFirstTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 3));

  print("test ${prefs.getBool('is_first_time')}");

  bool isFirstTime = prefs.getBool('is_first_time') ?? true;



  
  if (isFirstTime) {
    await prefs.setBool('is_first_time', false); // Mark as not first time
    return RouteName.walk_through; // Go to walkthrough
  } else {
    return RouteName.dashboard; // Go to home (or your main screen)
  }
}

  void isLogin(){


    // userPreference.getUser().then((value){

    //   print(value.token);
    //   print(value.isLogin);

    //   if(value.isLogin == false || value.isLogin.toString() == 'null'){
    //     Timer(const Duration(seconds: 3) ,
    //             () => Get.toNamed(RouteName.loginView) );
    //   }else {
    //     Timer(const Duration(seconds: 3) ,
    //             () => Get.toNamed(RouteName.homeView) );
    //   }
    // });


  }
}