import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/utlis/themeutlis.dart';
import 'package:valuemate/view_models/services/contorller/auth/auth_view_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController authController = Get.put(AuthController());

  final Map<String, dynamic> dummyCountry = {
    'name': 'United States',
    'phoneCode': '1',
    'countryCode': 'US',
    'example': '5551234567'
  };

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool isAcceptedTc = false;
  bool isFirstTimeValidation = true;

  Widget _buildTopWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            padding: EdgeInsets.all(16),
            child: Icon(Icons.person, color: Colors.white, size: 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Create Account',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).iconTheme.color,)
          ),
          SizedBox(height: 16),
          Text(
            'Join us today and start your journey',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: 32),
        ],
      ),
    );
  }

  Widget _buildFormWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 32),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: fNameCont,
            focus: fNameFocus,
            nextFocus: lNameFocus,
            errorThisFieldRequired: "This Field Is Required",
            decoration: inputDecoration(context, labelText: "First Name"),
            textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
            suffix: Icon(Icons.person, color: Colors.grey[800]),
          ),
          SizedBox(height: 16),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: lNameCont,
            focus: lNameFocus,
            nextFocus: emailFocus,
            errorThisFieldRequired: "This Field Is Required",
            decoration: inputDecoration(context, labelText: "Last Name"),
            textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
            suffix: Icon(Icons.person, color: Colors.grey[800]),
          ),
          SizedBox(height: 16),
          AppTextField(
            textFieldType: TextFieldType.EMAIL_ENHANCED,
            controller: emailCont,
            focus: emailFocus,
            nextFocus: mobileFocus,
            errorThisFieldRequired: "This Field Is Required",
            decoration: inputDecoration(context, labelText: "Email Address"),
            textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
            suffix: Icon(Icons.email, color: Colors.grey[800]),
            autoFillHints: [AutofillHints.email],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("+968",
                        style: TextStyle(
                            color: Theme.of(context).iconTheme.color)),
                    SizedBox(width: 4),
                    Icon(Icons.lock_outline,
                        color: Theme.of(context).iconTheme.color, size: 18),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  textFieldType: TextFieldType.PHONE,
                  controller: mobileCont,
                  focus: mobileFocus,
                  nextFocus: confirmPasswordFocus,
                  errorThisFieldRequired: "This Field Is Required",
                  decoration: inputDecoration(context, labelText: "Mobile Number")
                      .copyWith(contentPadding: EdgeInsets.only(left: 12)),
                  textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
                  suffix: Icon(Icons.phone, color: Colors.grey[800]),
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          AppTextField(
            textFieldType: TextFieldType.PASSWORD,
            controller: passwordCont,
            focus: confirmPasswordFocus,
            errorThisFieldRequired: "This Field Is Required",
            decoration: inputDecoration(context, labelText: "Password"),
            textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
            suffix: Icon(Icons.lock, color: Colors.grey[800]),
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              if (value.length < 8 || value.length > 12)
                return 'Password must be 8-12 characters';
              return null;
            },
            obscureText: true,
          ),
          SizedBox(height: 20),
          AppTextField(
            textFieldType: TextFieldType.PASSWORD,
            controller: confirmPasswordCont,
            focus: passwordFocus,
            errorThisFieldRequired: "This Field Is Required",
            decoration: inputDecoration(context, labelText: "Confirm Password"),
            textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
            suffix: Icon(Icons.lock, color: Colors.grey[800]),
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              if (value != passwordCont.text) return 'Passwords do not match';
              return null;
            },
            obscureText: true,
          ),
          SizedBox(height: 20),
          _buildTcAcceptWidget(),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleRegister,
              child: Text('SIGN UP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    if (formKey.currentState!.validate()) {
      if (!isAcceptedTc) {
        Get.snackbar('Error', 'Please accept terms and conditions');
        return;
      }

      try {
        await authController.register(
          fNameCont.text,
          lNameCont.text,
          emailCont.text,
          passwordCont.text,
          confirmPasswordCont.text,
        );
      } catch (e) {}
    } else {
      isFirstTimeValidation = false;
      setState(() {});
    }
  }

  Widget _buildTcAcceptWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: isAcceptedTc,
            onChanged: (value) => setState(() => isAcceptedTc = value!),
          ),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey),
              children: [
                TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign In',
                  style: TextStyle(
                      color: context.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ).onTap(() {
            Get.back();
          }),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Obx(
          () => Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    autovalidateMode: isFirstTimeValidation
                        ? AutovalidateMode.disabled
                        : AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTopWidget(),
                          _buildFormWidget(),
                          SizedBox(height: 8),
                          _buildFooterWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (authController.loading)
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
