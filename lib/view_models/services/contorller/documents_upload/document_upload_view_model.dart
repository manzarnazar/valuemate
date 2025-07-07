import 'dart:io';

import 'package:get/get.dart';
import 'package:valuemate/repository/document_repository/document_repository.dart';

class DocumentUploadController extends GetxController {
  final _repository = DocumentUploadRepository();

  RxBool isLoading = false.obs;
  RxString statusMessage = ''.obs;

  Future<void> uploadDocuments({
    required int valuationRequestId,
    required List<int> documentRequirementIds,
    required List<File> documentFiles,
    required String token,
  }) async {
    print("object");
    isLoading.value = true;
    try {
      var response = await _repository.uploadDocuments(
        valuationRequestId: valuationRequestId,
        documentRequirementIds: documentRequirementIds,
        documentFiles: documentFiles,
        token: token,
      );
      statusMessage.value = response['message'] ?? 'Upload successful';
    } catch (e) {
      print(e);
      statusMessage.value = e.toString();
    } finally {
      print(statusMessage);
      isLoading.value = false;
    }
  }
}
