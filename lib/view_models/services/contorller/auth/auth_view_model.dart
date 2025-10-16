import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valuemate/models/auth_model/auth_request_model.dart';
import 'package:valuemate/models/auth_model/auth_response.model.dart';
import 'package:valuemate/repository/auth_repository/auth_repository.dart';
import 'package:valuemate/res/routes/routes_name.dart';
import 'package:valuemate/view_models/services/contorller/auth/user_prefrence_view_model.dart';

class AuthController extends GetxController {
  final _authRepository = AuthRepository();

  final RxBool _loading = false.obs;
   RxBool isDeleteLoading = false.obs;
  bool get loading => _loading.value;

  final Rx<AuthResponseModel?> _authResponse = Rx<AuthResponseModel?>(null);
  AuthResponseModel? get authResponse => _authResponse.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  Future<void> login(String email, String password) async {
    _loading.value = true;
    _errorMessage.value = '';

    try {
      final request = LoginRequestModel(email: email, password: password);

      _authResponse.value = await _authRepository.login(request);
      print("Token: ${_authResponse.value?.data?.token}");

      if (_authResponse.value?.status == true &&
          _authResponse.value?.data != null) {
        // Save user data using UserPreference
        final saved = await UserPreference().saveUser(_authResponse.value!);

        if (saved) {
          Get.offAllNamed(RouteName.dashboard); // Clear navigation stack
        } else {
          _errorMessage.value = "Failed to save user data";
          Get.snackbar('Error', _errorMessage.value);
        }
      } else {
        _errorMessage.value = "Login failed: Invalid credentials";
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      print(e);
      Get.snackbar('Error', "Login failed: Invalid credentials",duration: Duration(seconds: 2));
    } finally {
      _loading.value = false;
    }
  }

  Future<void> register(String first_name, String last_name, String email,
      String password, String confirmPassword) async {
    _loading.value = true;
    _errorMessage.value = '';

    try {
      final request = RegisterRequestModel(
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
      );
      _authResponse.value = await _authRepository.register(request);

      if (_authResponse.value?.status == true) {
        await login(email, password);
      }
    } catch (e) {
      print(e);
      _errorMessage.value = e.toString();
      Get.snackbar('Error', _errorMessage.value);
    } finally {
      _loading.value = false;
    }
  }
Future<void> logout() async {
  _loading.value = true;
  _errorMessage.value = '';

  try {
    final token = await UserPreference().getToken();

    if (token != null && token.isNotEmpty) {
      final response = await _authRepository.logout(token);
      
      if (response.status == true) {
        await UserPreference().removeUser();
        _authResponse.value = null;
        Get.offAllNamed(RouteName.loginView);
      } else {
        _errorMessage.value = "Logout failed";
        Get.snackbar('Error', _errorMessage.value);
      }
    } else {
      _errorMessage.value = "No token found";
      Get.snackbar('Error', _errorMessage.value);
    }
  } catch (e) {
    _errorMessage.value = e.toString();
    Get.snackbar('Error', _errorMessage.value);
  } finally {
    _loading.value = false;
  }
}

Future<void> updateProfile(String firstName, String lastName, String email) async {
    _loading.value = true;
    _errorMessage.value = '';

    try {
      final token = await UserPreference().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final request = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

     final user = await UserPreference().getUser();
      

      final response = await _authRepository.edit_profile(request,user?.id, token);
      print("janab ${response.data}");

      if (response.status == true) {
        // Update local user data

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        _errorMessage.value = response.message ?? 'Failed to update profile';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      print('Update profile error: $e');
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      _loading.value = false;
    }
  }

    Future<void> deleteAccount() async {
    _loading.value = true;
    _errorMessage.value = '';

    try {
      final token = await UserPreference().getToken();
      final user = await UserPreference().getUser();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }
      if (user == null || user.id == null) {
        throw Exception('No user found');
      }
      isDeleteLoading.value =true;
      // You can pass an empty map or any required body as per your API
      final result = await _authRepository.deleteUser(user.id, token);

      if (result.status == true) {
        isDeleteLoading.value =false;
        await UserPreference().removeUser();
        _authResponse.value = null;
        Get.offAllNamed(RouteName.loginView);
        Get.snackbar(
          'Success',
          'Account deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        isDeleteLoading.value =false;
        _errorMessage.value = 'Failed to delete account';
        Get.snackbar('Error', _errorMessage.value);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      print('Delete account error: $e');
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      _loading.value = false;
    }
  }



  void clear() {
    _authResponse.value = null;
    _errorMessage.value = '';
  }
}
