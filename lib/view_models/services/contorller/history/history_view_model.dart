import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/models/history_model/history.dart';

import 'package:valuemate/repository/history_repository/history_repository.dart';

import 'package:get/get.dart';


class HistoryViewModel extends GetxController {
  final HistoryRepository _repository = HistoryRepository();

  var requests = <HistoryModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> getRequests() async {
     final prefs = await SharedPreferences.getInstance();
      final String? tok = prefs.getString('token');
      print("yes yes yes this is tok $tok");
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


// class HistoryViewModel extends ChangeNotifier {
//   final HistoryRepository _repository = HistoryRepository();

//   List<HistoryModel> _requests = [];
//   List<HistoryModel> get requests => _requests;

  

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _error = '';
//   String get error => _error;

//   Future<void> getHistory() async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();
//      final prefs = await SharedPreferences.getInstance();
//       final String? tok = prefs.getString('token');
//       print("yes yes yes this is tok $tok");
//       // print("Token from SharedPreferences: $tok");

//     try {
//       _requests = await _repository.fetchHistory(tok.toString());
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
