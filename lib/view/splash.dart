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
  final SplashServices _splashServices = SplashServices();
  final ConstantsController _constantsController =
      Get.put(ConstantsController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final routeName = await _splashServices.checkFirstTime();
    await _constantsController.fetchConstants();
    Get.offAllNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Center(
          child: Image.asset(
            "assets/images/logo.png",
         
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
