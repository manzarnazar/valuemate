import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/history_model/history.dart';


class HistoryRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<List<HistoryModel>> fetchHistory(String token) async {
    try {
      final response = await _apiServices.postApiWithToken({}, "https://valuma8.com/api/request-history", token);

      if (response['status'] == true && response['data'] != null) {
        List data = response['data'];
        return data.map((e) => HistoryModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch request data');
      }
    } catch (e) {
      rethrow;
    }
  }
}
