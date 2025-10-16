import 'package:get/get.dart';
import 'package:valuemate/data/network/base_api_services.dart';
import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/auth_model/auth_request_model.dart';
import 'package:valuemate/models/auth_model/auth_response.model.dart';

class AuthRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      dynamic response = await _apiServices.postApi(
        request.toJson(),
        "https://valuma8.com/api/login",
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      dynamic response = await _apiServices.postApi(
        request.toJson(),
        "https://valuma8.com/api/register",
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> logout(String token) async {
    try {
      dynamic response = await _apiServices.postApiWithToken(
        {}, // empty body
        "https://valuma8.com/api/logout",
        token,
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> edit_profile(request, id, String token) async {
    try {
      dynamic response = await _apiServices.postApiWithToken(
        request, // empty body
        "https://valuma8.com/api/users/update/$id",
        token,
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> deleteUser(id, String token) async {
    try {
      dynamic response = await _apiServices.postApiWithToken(
        {}, // Pass the request/body here (can be {} if empty)
        "https://valuma8.com/api/users/delete/$id",
        token,
      );

      // You can check response for success/failure as per your API
      // For now, return true if no exception
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
