import 'package:valuemate/data/network/base_api_services.dart';
import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/valuation_request_model/valuation_request_model.dart';

class ValuationRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> createValuationRequest(
      ValuationRequest data, String token) async {
    try {
      print('Sending request with data: ${data.toJson()}');
      dynamic response = await _apiServices.postApiWithToken(
        data.toJson(),
        'https://valuma8.com/api/create-valuation-request',
        token,
      );
      

      return response;
    } catch (e, stackTrace) {
      print('Error in createValuationRequest: $e');
      print('Stack trace: $stackTrace');
      return e;
    }
  }
}