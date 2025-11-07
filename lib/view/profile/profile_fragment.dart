import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:valuemate/res/routes/routes.dart';
import 'package:valuemate/res/routes/routes_name.dart';
import 'package:valuemate/view/profile/legal_page.dart';
import 'package:valuemate/view/profile/theme_selection_dialog.dart';
import 'package:valuemate/view_models/services/contorller/auth/auth_view_model.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({super.key});

  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final AuthController authController = Get.put(AuthController());
  final ConstantsController _constantController =
      Get.find<ConstantsController>();

  bool isLoggedIn = false;
  String? fname;
  String? lname;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? name = prefs.getString('first_name');
      final String? lastname = prefs.getString('last_name');
      final String? em = prefs.getString('email');
      final String? tok = prefs.getString('token');
      final bool? islog = prefs.getBool('isLogin');
      print("Token from SharedPreferences: $tok");

      if (mounted) {
        setState(() {
          isLoggedIn = islog ?? false;
          fname = name;
          lname = lastname;
          email = em;
        });
      }
    } catch (e) {
      print("Error loading token: $e");
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text(
            'are_you_sure_delete'.tr),
        actions: [
          TextButton(
            child: Text('cancel'.tr),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('delete'.tr, style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      authController.deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "profile".tr,
        textColor: white,
        textSize: 18,
        elevation: 0.0,
        color: context.primaryColor,
        showBack: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            if (isLoggedIn) _buildUserProfileSection(),
            _buildAboutAppSection(),
            if (isLoggedIn) _buildDangerZoneSection(),
            if (!isLoggedIn) _buildSignInButton(),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch dialer';
      }
    } catch (e) {
      print('Error launching dialer: $e');
      Fluttertoast.showToast(
        msg: "could_not_launch_dialer".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Widget _buildUserProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg'),
                    ),
                    // Fixed: Positioned is now direct child of Stack
                    Positioned(
                      bottom: -6,
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteName.edit_profile);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('edit'.tr,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${fname ?? ''} ${lname ?? ''}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                              fontSize: 16)),
                      Text('${email ?? ''}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAppSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'privacy_policy'.tr,
            onTap: () {
              Get.to(() => LegalPageView(isTerms: false));
            },
          ),
          _buildListTile(
            icon: Icons.description,
            title: 'terms_conditions'.tr,
            onTap: () {
              Get.to(() => LegalPageView(isTerms: true));
            },
          ),
          _buildListTile(
            icon: Icons.support,
            title: 'support_chat'.tr,
            onTap: () {
              Get.snackbar("support_chat".tr, "support_chat_working".tr);
            },
          ),
          _buildListTile(
            icon: Icons.phone,
            title: 'helpline_number'.tr,
            onTap: () async {
              try {
                final helplineSetting = _constantController.settings.firstWhere(
                  (setting) => setting.key == "helpline_number",
                );
                final helplineNumber = helplineSetting.value;
                await _launchDialer(helplineNumber);
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "no_helpline".tr,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
          ),
          _buildListTile(
            icon: Icons.dark_mode,
            title: 'theme'.tr,
            onTap: () async {
              await showInDialog(
                context,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          _buildListTile(
            icon: Icons.language,
            title: 'language'.tr,
            onTap: () async {
              final selected = await showDialog<Locale>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('select_language'.tr, style: TextStyle(color: Theme.of(context).iconTheme.color),),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('english'.tr),
                        trailing: Get.locale?.languageCode == 'en'
                            ? const Icon(Icons.check, color: Colors.blue) : null,
                        onTap: () => Navigator.of(context).pop(const Locale('en', 'US')),
                      ),
                      ListTile(
                        title: Text('arabic'.tr),
                        trailing: Get.locale?.languageCode == 'ar'
                            ? const Icon(Icons.check, color: Colors.blue) : null,
                        onTap: () => Navigator.of(context).pop(const Locale('ar', 'SA')),
                      ),
                    ],
                  ),
                ),
              );
              if (selected != null) {
                Get.updateLocale(selected);
                await setValue('locale','${selected.languageCode}_${selected.countryCode}');
              }
            },
          ),
          if (isLoggedIn)
            Obx(() => ListTile(
                  leading:
                      const Icon(Icons.delete, color: Colors.red, size: 20),
                  title: Text(
                    'dlt_account'.tr,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  trailing: authController.isDeleteLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : Icon(Icons.chevron_right,
                          color: Theme.of(context).iconTheme.color),
                  onTap: authController.isDeleteLoading.value
                      ? null
                      : _showDeleteAccountDialog,
                )),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Obx(() {
              return SizedBox(
                height: 48,
                child: authController.loading
                    ? const Center(child: CircularProgressIndicator())
                    : TextButton(
                        onPressed: () {
                          authController.logout();
                        },
                        child: Text(
                          'logout'.tr,
                          style: TextStyle(
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: _buildListTile(
        icon: Icons.login,
        title: 'sign_in'.tr,
        onTap: () {
          Get.toNamed(RouteName.loginView);
        },
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          child: Text('v1.0.0'.tr, style: TextStyle(color: Colors.grey)),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'My App',
              applicationVersion: '1.0.0',
              applicationIcon: const FlutterLogo(size: 50),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    final textColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(icon,
          color: color ?? Theme.of(context).iconTheme.color, size: 20),
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
      ),
      trailing:
          Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
      onTap: onTap ?? () {},
    );
  }
}