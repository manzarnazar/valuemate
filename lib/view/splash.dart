import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';
import 'package:valuemate/view_models/services/splash_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices _splashServices = SplashServices();
  final ConstantsController _constantsController =
      Get.put(ConstantsController(), permanent: true);

  @override
  void initState() {
    super.initState();

    _initializeApp(); 
  }

  Future<void> _initializeApp() async {
    await _splashServices.checkFirstTime();

    final routeName = await _splashServices.checkFirstTime();
    await _constantsController.fetchConstants();
    Get.offAllNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF560574),
        body: Center(child: Image.asset("assets/images/splash_screen.jpeg")));
  }
}
