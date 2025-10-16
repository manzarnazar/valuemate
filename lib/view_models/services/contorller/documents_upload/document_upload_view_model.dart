import 'dart:io';

import 'package:get/get.dart';
import 'package:valuemate/data/app_exceptions.dart';
import 'package:valuemate/repository/document_repository/document_repository.dart';

class DocumentUploadController extends GetxController {
  final _repository = DocumentUploadRepository();

  final RxBool isLoading = false.obs;
  final RxString statusMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  Future<void> uploadDocuments({
    required int valuationRequestId,
    required List<int> documentRequirementIds,
    required List<File> documentFiles,
    required List<String> documentTextValues,
    required String token,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    statusMessage.value = '';

    try {
      final response = await _repository.uploadDocuments(
        valuationRequestId: valuationRequestId,
        documentRequirementIds: documentRequirementIds,
        documentFiles: documentFiles,
        documentTextValues: documentTextValues,
        token: token,
      );

      if (response is InternetException) {
        errorMessage.value = 'No internet connection';
        Get.snackbar('Error', errorMessage.value);
      } else if (response is RequestTimeOut) {
        errorMessage.value = 'Request timed out';
        Get.snackbar('Error', errorMessage.value);
      } else if (response is Exception) {
        errorMessage.value = 'Something went wrong: ${response.toString()}';
        Get.snackbar('Error', errorMessage.value);
      } else {
        // If response is valid
        statusMessage.value = response['message'] ?? 'Documents uploaded successfully';
        Get.snackbar('Success', statusMessage.value);
        print("Response is: $response");
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}