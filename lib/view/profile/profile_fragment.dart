import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valuemate/res/routes/routes_name.dart';
import 'package:valuemate/view/profile/setting.dart';
import 'package:valuemate/view/profile/theme_selection_dialog.dart';
import 'package:valuemate/view_models/services/contorller/auth/auth_view_model.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';

class ProfileFragment extends StatefulWidget {
  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final AuthController authController = Get.put(AuthController());
  final ConstantsController _constantController =
      Get.find<ConstantsController>();

  bool isLoggedIn = false; // Change this to false to see the sign-in button
  String? fname;
  String? lname;
  String? email;

  @override
  void initState() {
    super.initState();

    // Load token asynchronously
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Profile",
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
            // _buildGeneralSection(),
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
        msg: "Could not launch dialer",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Widget _buildUserProfileSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg'),
                    ),
                    Positioned(
                      bottom: -6,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('Edit',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${fname} ${lname}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                              fontSize: 16)),
                      Text('$email', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          //     color: context.primaryColor,
          //   ),
          //   child: Padding(
          //     padding: EdgeInsets.all(16),
          //     child: Row(
          //       children: [
          //         Icon(Icons.account_balance_wallet, color: Colors.white),
          //         SizedBox(width: 8),
          //         Text('Wallet Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          //         Spacer(),
          //         Text('\$$walletBalance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('GENERAL',
                        style: TextStyle(
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          _buildListTile(icon: Icons.history, title: 'Wallet History'),
          _buildListTile(icon: Icons.credit_card, title: 'Bank Details'),
          _buildListTile(icon: Icons.favorite, title: 'Favorites'),
          _buildListTile(icon: Icons.people, title: 'Favorite Providers'),
          _buildListTile(icon: Icons.article, title: 'Blogs'),
          _buildListTile(icon: Icons.star, title: 'Rate Us'),
          _buildListTile(icon: Icons.reviews, title: 'My Reviews'),
          _buildListTile(icon: Icons.help, title: 'Help Desk'),
        ],
      ),
    );
  }

  Widget _buildAboutAppSection() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: context.primaryColor.withOpacity(0.1),
          //           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          //         ),
          //         child: Padding(
          //           padding: EdgeInsets.all(16),
          //           child: Text('ABOUT APP', style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold)),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              Get.snackbar("Privacy Policy tapped", "Coming soon.....");
              // Handle Privacy Policy tap
              print('Privacy Policy tapped');
            },
          ),
          _buildListTile(
            icon: Icons.description,
            title: 'Terms & Conditions',
            onTap: () {
              Get.snackbar("Terms & Conditions tapped", "Coming soon.....");
              // Handle Terms & Conditions tap
              print('Terms & Conditions tapped');
            },
          ),
          _buildListTile(
            icon: Icons.support,
            title: 'Support Chat',
            onTap: () {
              Get.snackbar(
                  "Terms & Conditions tapped", "We are working on it.....");
              // Handle Help & Support tap
              print('Help & Support tapped');
            },
          ),
          _buildListTile(
            icon: Icons.phone,
            title: 'Helpline Number',
            onTap: () async {
              try {
                final helplineSetting = _constantController.settings.firstWhere(
                  (setting) => setting.key == "helpline_number",
                );
                final helplineNumber = helplineSetting.value;
                print('Helpline Number tapped: $helplineNumber');
                await _launchDialer(helplineNumber);
              } catch (e) {
                print('Error finding helpline number: $e');
                Fluttertoast.showToast(
                  msg: "Could not find helpline number",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
          ),

          _buildListTile(
            icon: Icons.dark_mode,
            title: 'Theme',
            onTap: () async {
              await showInDialog(
                context,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Obx(() {
              return Container(
                height: 48, // Fixed height for both button and loader
                child: authController.loading
                    ? const Center(child: CircularProgressIndicator())
                    : TextButton(
                        onPressed: () {
                          authController.logout();
                        },
                        child: Text(
                          'Logout',
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
      margin: EdgeInsets.all(16),
      color: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: _buildListTile(
        icon: Icons.login,
        title: 'Sign In',
        onTap: () {
          Get.toNamed(RouteName.loginView);
        },
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          child: Text('v1.0.0', style: TextStyle(color: Colors.grey)),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'My App',
              applicationVersion: '1.0.0',
              applicationIcon: FlutterLogo(size: 50),
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
      onTap: onTap ??
          () {}, // Provide empty function if onTap is null to make it tappable
    );
  }
}
