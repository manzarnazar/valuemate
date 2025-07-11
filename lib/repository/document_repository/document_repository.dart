import 'dart:async';
import 'dart:io';

import 'package:valuemate/data/app_exceptions.dart';
import 'package:valuemate/data/network/network_api_services.dart';
import 'package:http/http.dart' as http;

class DocumentUploadRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> uploadDocuments({
    required int valuationRequestId,
    required List<int> documentRequirementIds,
    required List<File> documentFiles,
    required String token,
  }) async {
    var uri = Uri.parse('https://valuma8.com/api/upload-valuation-documents'); // replace with actual URL

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['valuation_request_id'] = valuationRequestId.toString();

    for (int i = 0; i < documentRequirementIds.length; i++) {
      request.fields['document_requirement_id[$i]'] = documentRequirementIds[i].toString();
      print(request.fields['document_requirement_id[$i]']);
    }

    for (int i = 0; i < documentFiles.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'document_file[$i]',
        documentFiles[i].path,
      ));
    }

   try {
  final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
  final response = await http.Response.fromStream(streamedResponse);
  return _apiService.returnResponse(response);
} on SocketException {
  throw InternetException('No internet connection');
} on TimeoutException {
  throw RequestTimeOut('Request timed out');
} on http.ClientException catch (e) {
  if (e != null || e.message.contains('SocketException')) {
    throw InternetException('');
  }
  throw FetchDataException('Client error: ${e.message}');
} catch (e) {
  print('Unhandled error in uploadDocuments: $e');
  rethrow;
}
  }
}
