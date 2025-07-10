import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:valuemate/data/app_exceptions.dart';
import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/valuation_request_model/valuation_request_model.dart';
import 'package:valuemate/repository/valuation_request_repository/valuation_request_repository.dart';

class ValuationViewModel extends GetxController {
  final _repository = ValuationRepository();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt  request_id = 0.obs;
  final RxDouble  price = 0.0.obs;


  void resetIdValue (){
    request_id.value = 0;
  }

  Future<void> createValuationRequest(ValuationRequest data, String token) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _repository.createValuationRequest(data, token);

    if (response is InternetException) {
      errorMessage.value = 'No internet connection';
      Get.snackbar('Error', 'Failed to load constants: ${errorMessage.value}');
    } else if (response is RequestTimeOut) {
      errorMessage.value = 'Request timed out';
    }
     else if (response is Exception) {
      errorMessage.value = 'Something went wrong: ${response.toString()}';
      Get.snackbar('Error', 'Failed to load constants: ${errorMessage.value}');
    } else {
      request_id.value = response['data']['id'];
      price.value = double.tryParse(response['data']['amount'].toString()) ?? 0.0;
    }
  } catch (e) {
    errorMessage.value = 'Something went wrong: ${e.toString()}';
    Get.snackbar('Error', 'Failed to load constants: ${errorMessage.value}');
  } finally {
    isLoading.value = false;
    
  }
}


  Future<Map<String, dynamic>> initiatePayment({
  required int valuationRequestId,
  required int paymentMethodId,
  required String token,
}) async {
  try {
    final response = await NetworkApiServices().getApi(
"https://valuma8.com/api/checkout-test?valuation_request_id=$valuationRequestId"
    );
    
    return response;
  } catch (e) {
    print(e);
    rethrow;
  }
}
}