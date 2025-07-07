import 'dart:io';

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

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return _apiService.returnResponse(response);
  }
}
