import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/utlis/themeutlis.dart';
import 'package:valuemate/view/auth/register_page.dart';

import 'package:valuemate/view_models/services/contorller/auth/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;

  const LoginScreen({
    Key? key,
    this.isFromDashboard,
    this.isFromServiceBooking,
    this.returnExpected = false,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController authController = Get.put(AuthController());

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = true;
  bool obscurePassword = true;

  // Dummy configuration
  bool googleLoginEnabled = true;
  bool appleLoginEnabled = true;
  bool otpLoginEnabled = true;

  @override
  void initState() {
    super.initState();
  }

  void _handleLogin() {
    if (formKey.currentState!.validate()) {
      authController.login(
        emailCont.text.trim(),
        passwordCont.text.trim(),
      );
    }
  }

  void _fillDummyData() {
    setState(() {
      emailCont.text = 'demo@gmail.com';
      passwordCont.text = 'password';
      // Trigger validation after filling
      formKey.currentState?.validate();
    });
  }

  Widget _buildTopWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Text("welcome_back".tr,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).iconTheme.color)),
          16.height,
          Text("login_to_continue".tr,
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          // Add the dummy data button here
          // TextButton(
          //   onPressed: _fillDummyData,
          //   child: Text(
          //     "Use Demo Account",
          //     style: TextStyle(
          //       color: Theme.of(context).primaryColor,
          //       decoration: TextDecoration.underline,
          //       fontStyle: FontStyle.italic,
          //     ),
          //   ),
          // ),
          16.height,
        ],
      ),
    );
  }

  Widget _buildRememberWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isRemember,
                    onChanged: (value) => setState(() => isRemember = value!),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  Text("Remember me", style: TextStyle(color: Colors.grey)),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to forgot password screen
                  // Get.toNamed(Routes.FORGOT_PASSWORD);
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          24.height,
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              return ElevatedButton(
                onPressed: authController.loading ? null : _handleLogin,
                child: authController.loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("Sign In"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?",
                  style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                _buildTopWidget(),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    children: [
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.EMAIL_ENHANCED,
                        controller: emailCont,
                        focus: emailFocus,
                        nextFocus: passwordFocus,
                        errorThisFieldRequired: "Email Field Is Required",
                        decoration:
                            inputDecoration(context, labelText: "Email"),
                        textStyle:
                            TextStyle(color: Theme.of(context).iconTheme.color),
                        suffix: Icon(
                          Icons.email,
                          color: Colors.grey[800],
                        ),
                        autoFillHints: [AutofillHints.email],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.PASSWORD,
                        controller: passwordCont,
                        focus: passwordFocus,
                        obscureText: true,
                        textStyle:
                            TextStyle(color: Theme.of(context).iconTheme.color),
                        suffixPasswordVisibleWidget: Icon(
                          Icons.visibility_off,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[800]
                                  : Colors.white,
                        ).paddingAll(14),
                        suffixPasswordInvisibleWidget: Icon(
                          Icons.visibility,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[800]
                                  : Colors.white,
                        ).paddingAll(14),
                        decoration:
                            inputDecoration(context, labelText: "Password"),
                        autoFillHints: [AutofillHints.password],
                        isValidationRequired: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "This field is required";
                          } else if (val.length < 8) {
                            return "Password length should be at least 8 characters";
                          }
                          return null;
                        },
                        onFieldSubmitted: (s) {
                          _handleLogin();
                        },
                      ),
                    ],
                  ),
                ),
                _buildRememberWidget(),
                30.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
