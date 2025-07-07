class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequestModel {
  final String first_name;
  final String last_name;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterRequestModel({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}