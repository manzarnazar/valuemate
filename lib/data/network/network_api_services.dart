import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:valuemate/data/network/base_api_services.dart';
import 'package:http/http.dart' as http;

import '../app_exceptions.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) {
      print(url);
    }

    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url));
      responseJson = returnResponse(response);

      if (kDebugMode) {
        print(responseJson);
      }
      return responseJson;
    } catch (e) {
      if (kDebugMode) {
        Get.snackbar("Error", e.toString());
      }
      rethrow;
    }
  }

  @override
  Future<dynamic> getApiWithToken(String url, String token) async {
    if (kDebugMode) {
      print(url);
    }

    dynamic responseJson;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      responseJson = returnResponse(response);

      if (kDebugMode) {
        print(responseJson);
      }
      return responseJson;
    } catch (e) {
      if (kDebugMode) {
        Get.snackbar("Error", e.toString());
      }
      rethrow;
    }
  }

  @override
Future<dynamic> postApi(var data, String url) async {
  if (kDebugMode) {
    print("POST URL: $url");
    print("POST Data: $data");
  }

  dynamic responseJson;
  try {
    final response = await http
        .post(Uri.parse(url), body: data);

    responseJson = returnResponse(response);

    if (kDebugMode) {
      print("Response: $responseJson");
    }

    return responseJson;
  
  } catch (e) {
    throw FetchDataException('Unexpected error: $e');
  }
}


  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      default:
        throw FetchDataException(
            'Error accoured while communicating with server ${response.statusCode}');
    }
  }

  @override
  Future<dynamic> postApiWithToken(var data, String url, String token) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print("check ${response.body}");
      }
      responseJson = returnResponse(response);
      return responseJson;
    } on http.ClientException catch (e) {
      if (e.message.contains('SocketException')) {
        throw InternetException('');
      }
      throw FetchDataException('Client error: ${e.message}');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }
}
