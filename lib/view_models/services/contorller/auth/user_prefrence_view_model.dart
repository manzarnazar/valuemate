

import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/models/auth_model/auth_response.model.dart';

class UserPreference {
  static const _tokenKey = 'token';
  static const _userId = 'user_id';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _emailKey = 'email';
  static const _isLoginKey = 'isLogin';

  Future<bool> saveUser(AuthResponseModel responseModel) async {
    final sp = await SharedPreferences.getInstance();
    
    await Future.wait([
      sp.setString(_tokenKey, responseModel.data?.token ?? ''),
      sp.setString(_firstNameKey, responseModel.data?.user?.firstName ?? ''),
      sp.setInt(_userId, responseModel.data?.user?.id ?? 0),
      sp.setString(_lastNameKey, responseModel.data?.user?.lastName ?? ''),
      sp.setString(_emailKey, responseModel.data?.user?.email ?? ''),
      sp.setBool(_isLoginKey, true),
    ]);

    return true;
  }

  Future<String?> getToken() async {
  final sp = await SharedPreferences.getInstance();
  return sp.getString(_tokenKey);
}


  Future<UserModel?> getUser() async {
    final sp = await SharedPreferences.getInstance();
    
    final token = sp.getString(_tokenKey);
    if (token == null) return null;

    return UserModel(
      id: sp.getInt(_userId) ?? 0, 
      firstName: sp.getString(_firstNameKey) ?? '',
      lastName: sp.getString(_lastNameKey) ?? '',
      email: sp.getString(_emailKey) ?? '',
      phone: null,
      emailVerifiedAt: null,
      createdAt: '',
      updatedAt: '',
    );
  }

  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_isLoginKey) ?? false;
  }

  Future<bool> removeUser() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    return true;
  }
}