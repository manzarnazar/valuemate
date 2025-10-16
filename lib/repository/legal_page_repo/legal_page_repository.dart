import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/legal_page/legal_page_model.dart';

class LegalRepository {
    final NetworkApiServices _apiServices = NetworkApiServices();

  Future<LegalModel> fetchTerms(String token) async {
    try {
      final response = await _apiServices.postApiWithToken({}, "https://valuma8.com/api/terms", token);

      if (response['status'] == true && response['data'] != null) {
        var data = response['data'];
        return LegalModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch request data');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<LegalModel> fetchPolicy(String token) async {
    try {
      final response = await _apiServices.postApiWithToken({}, "https://valuma8.com/api/policy", token);

      if (response['status'] == true && response['data'] != null) {
        var data = response['data'];
        return LegalModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch request data');
      }
    } catch (e) {
      rethrow;
    }
  }
}