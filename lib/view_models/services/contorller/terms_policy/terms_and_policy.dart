import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valuemate/models/legal_page/legal_page_model.dart';
import 'package:valuemate/repository/legal_page_repo/legal_page_repository.dart';

class TermsAndPolicyController extends GetxController {
   final LegalRepository _repository = LegalRepository();

  final isLoading = false.obs;
  final legalModel = Rxn<LegalModel>();
  final error = ''.obs;

  
  Future<void> fetchTerms() async {
    isLoading(true);
    error('');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final result = await _repository.fetchTerms(token!);
      legalModel(result);
    } catch (e) {
      error(e.toString());
      Get.snackbar('Error', 'Failed to load Terms: $e');
    } finally {
      isLoading(false);
    }
  }
  Future<void> fetchPolicy() async {
    isLoading(true);
    error('');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final result = await _repository.fetchPolicy(token!);
      legalModel(result);
    } catch (e) {
      error(e.toString());
      Get.snackbar('Error', 'Failed to load Terms: $e');
    } finally {
      isLoading(false);
    }
  }
  
}