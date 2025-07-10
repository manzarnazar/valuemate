import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:valuemate/data/network/base_api_services.dart';
// import 'package:getx_mvvm/data/network/base_api_services.dart';
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
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    
    print(responseJson);
    return responseJson;
    }catch(e){
      Get.snackbar("Error", e.toString());
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
        .post(Uri.parse(url), body: data)
        .timeout(const Duration(seconds: 10));

    responseJson = returnResponse(response);

    if (kDebugMode) {
      print("Response: $responseJson");
    }

    return responseJson;
  } on SocketException {
    throw InternetException('No internet connection');
  } on TimeoutException {
    throw RequestTimeOut('Request timed out');
  } on http.ClientException catch (e) {
    throw FetchDataException('Client error: ${e.message}');
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
      ).timeout(const Duration(seconds: 10));

      print("check ${response.body}");
      responseJson = returnResponse(response);
      return responseJson;
    } on SocketException {
      throw InternetException('No internet connection');
    } on TimeoutException {
      throw RequestTimeOut('Request timed out');
    } on http.ClientException catch (e) {
      if (e != null || e.message.contains('SocketException')) {
        throw InternetException('');
      }
      throw FetchDataException('Client error: ${e.message}');
    }
  }
}
