import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';
import 'package:valuemate/view_models/services/splash_service.dart';
import 'package:nb_utils/nb_utils.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices _splashServices = SplashServices();
  final ConstantsController _constantsController = Get.put(ConstantsController());

 @override
void initState() {
  super.initState();
  _initializeApp(); // ✅ handle everything here
}

Future<void> _initializeApp() async {
  // ✅ Wait for constants to load
  // await _constantsController.fetchConstants();

  // ✅ Wait for splash tasks (like checking onboarding or login)
  await _splashServices.checkFirstTime();

  _printConstantsValues();

  final routeName = await _splashServices.checkFirstTime();
  Get.offAllNamed(routeName);
}


  void _printConstantsValues() {
    debugPrint('===== Constants Values =====');
    
   debugPrint('\nProperty Service Types:');
  for (var propertyService in _constantsController.propertyServiceTypes) {
    debugPrint('  ${propertyService.propertyType} (ID: ${propertyService.propertyTypeId}):');
    for (var service in propertyService.services) {
      debugPrint('    - ${service.id}: ${service.serviceType} (Service Type ID: ${service.serviceTypeId})');
    }
  }
    // // Print service types
    // debugPrint('\nService Types:');
    // for (var type in _constantsController.serviceTypes) {
    //   debugPrint('  ${type.serviceTypeId}: ${type.serviceType}');
    // }
    
    // // Print companies
    // debugPrint('\nCompanies:');
    // for (var company in _constantsController.companies) {
    //   debugPrint('  ${company.id}: ${company.name}');
    // }
    
    // // Print locations
    // debugPrint('\nLocations:');
    // for (var location in _constantsController.locations) {
    //   debugPrint('  ${location.id}: ${location.name}');
    // }
    
    // Print property types
    debugPrint('\nProperty Types:');
    for (var type in _constantsController.propertyTypes) {
      debugPrint('  ${type.id}: ${type.name}');
    }
    
    // // Print request types
    // debugPrint('\nRequest Types:');
    // for (var type in _constantsController.requestTypes) {
    //   debugPrint('  ${type.id}: ${type.name}');
    // }
    
    // // Print settings
    // debugPrint('\nSettings:');
    // for (var setting in _constantsController.settings) {
    //   debugPrint('  ${setting.key}: ${setting.value}');
    // }
    
    // debugPrint('===========================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF560574),
      body: Center(child: Image.asset("assets/images/splash_screen.jpeg"))

    );
  }
}