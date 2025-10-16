import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/utlis/themeutlis.dart';
import 'package:valuemate/view_models/services/contorller/auth/auth_view_model.dart';
import 'package:valuemate/view_models/services/contorller/auth/user_prefrence_view_model.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController authController = Get.put(AuthController());

  // Controllers
  final fNameCont = TextEditingController();
  final lNameCont = TextEditingController();
  final emailCont = TextEditingController();
  final mobileCont = TextEditingController();

  final fNameFocus = FocusNode();
  final lNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final mobileFocus = FocusNode();

  bool isFirstTimeValidation = true;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupChangeListeners();
  }

  void _loadUserData() async {
    final user = await UserPreference().getUser();
    if (user != null) {
      setState(() {
        fNameCont.text = user.firstName;
        lNameCont.text = user.lastName;
        emailCont.text = user.email;
        // mobileCont.text = user.mobile ?? "";
      });
    }
  }

  void _setupChangeListeners() {
    for (var controller in [fNameCont, lNameCont, emailCont, mobileCont]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (!hasChanges) {
      setState(() => hasChanges = true);
    }
  }

  @override
  void dispose() {
    fNameCont.dispose();
    lNameCont.dispose();
    emailCont.dispose();
    mobileCont.dispose();
    fNameFocus.dispose();
    lNameFocus.dispose();
    emailFocus.dispose();
    mobileFocus.dispose();
    super.dispose();
  }

  Widget _buildTopWidget() {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: context.primaryColor.withOpacity(0.1),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: context.primaryColor,
            child: Icon(Icons.person, color: Colors.white, size: 50),
          ),
        ),
      
        16.height,
        Text('Edit Profile',
            style: boldTextStyle(size: 22, color: context.primaryColor)),
        8.height,
        Text(
          'Update your profile information',
          style: secondaryTextStyle(size: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormWidget() {
    return Column(
      children: [
        32.height,
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: fNameCont,
          focus: fNameFocus,
          nextFocus: lNameFocus,
          errorThisFieldRequired: "First name is required",
          decoration: inputDecoration(context, labelText: "First Name"),
          textStyle:TextStyle(color: Theme.of(context).iconTheme.color),
          suffix: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: lNameCont,
          focus: lNameFocus,
          nextFocus: emailFocus,
          errorThisFieldRequired: "Last name is required",
          decoration: inputDecoration(context, labelText: "Last Name",),
          textStyle:TextStyle(color: Theme.of(context).iconTheme.color),
          suffix: Icon(Icons.person_outline, color: Theme.of(context).iconTheme.color),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.EMAIL_ENHANCED,
          controller: emailCont,
          focus: emailFocus,
          nextFocus: mobileFocus,
          errorThisFieldRequired: "Email is required",
          decoration: inputDecoration(context, labelText: "Email Address"),
          textStyle:TextStyle(color: Theme.of(context).iconTheme.color),
          suffix: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
          autoFillHints: [AutofillHints.email],
        ),
        16.height,
        // AppTextField(
        //   textFieldType: TextFieldType.PHONE,
        //   controller: mobileCont,
        //   focus: mobileFocus,
        //   errorThisFieldRequired: "Mobile is required",
        //   decoration: inputDecoration(context, labelText: "Mobile Number"),
        //   suffix: Icon(Icons.phone, color: Theme.of(context).iconTheme.color),
        // ),
        32.height,
        AppButton(
          text: "Save Changes",
          color: hasChanges ? context.primaryColor : Colors.grey,
          textColor: Colors.white,
          // width,
          onTap: hasChanges ? _handleSaveProfile : null,
        ),
      ],
    );
  }

  void _handleSaveProfile() async {
    if (formKey.currentState!.validate()) {
      try {
        await authController.updateProfile(
          fNameCont.text,
          lNameCont.text,
          emailCont.text,
          // mobileCont.text,
        );

        setState(() => hasChanges = false);

        Get.snackbar('Success', 'Profile updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar('Error', 'Failed to update profile',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      isFirstTimeValidation = false;
      setState(() {});
    }
  }

  void _showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(2)),
            ),
            20.height,
            Text('Change Profile Picture',
                style: boldTextStyle(size: 18, color: context.primaryColor)),
            20.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageOption(Icons.camera_alt, "Camera", context.primaryColor,
                    () => Get.back()),
                _imageOption(Icons.photo_library, "Gallery",
                    context.primaryColor, () => Get.back()),
                _imageOption(Icons.delete, "Remove", Colors.red, () => Get.back()),
              ],
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _imageOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration:
              BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 30),
        ).onTap(onTap),
        8.height,
        Text(label, style: secondaryTextStyle(size: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: WillPopScope(
        onWillPop: () async {
          if (hasChanges) {
            bool? shouldLeave = await Get.dialog<bool>(
              AlertDialog(
                title: Text('Unsaved Changes'),
                content: Text('You have unsaved changes. Leave without saving?'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text('Leave')),
                ],
              ),
            );
            return shouldLeave ?? false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (hasChanges)
                TextButton(
                  onPressed: _handleSaveProfile,
                  child:
                      Text('Save', style: boldTextStyle(color: context.primaryColor)),
                )
            ],
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
          body: Obx(
            () => Stack(
              alignment: Alignment.center,
              children: [
                Form(
                  key: formKey,
                  autovalidateMode: isFirstTimeValidation
                      ? AutovalidateMode.disabled
                      : AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTopWidget(),
                        _buildFormWidget(),
                        30.height,
                      ],
                    ),
                  ),
                ),
                if (authController.loading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
