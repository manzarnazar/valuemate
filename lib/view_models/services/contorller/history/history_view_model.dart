
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valuemate/models/history_model/history.dart';
import 'package:valuemate/repository/history_repository/history_repository.dart';

class HistoryViewModel extends GetxController {
  final HistoryRepository _repository = HistoryRepository();

  var requests = <HistoryModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;


  var selectedStatusId = 0.obs;


  List<HistoryModel> get filteredRequests {
    if (selectedStatusId.value == 0) return requests;
    return requests.where((req) => req.status_id == selectedStatusId.value).toList();
  }

  Future<void> getRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tok = prefs.getString('token');

    try {
      isLoading(true);
      error('');
      final data = await _repository.fetchHistory(tok.toString());
      requests.assignAll(data);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
