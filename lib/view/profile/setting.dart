import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/view_models/services/contorller/auth/auth_view_model.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AuthController authController = Get.find<AuthController>();
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
        appBarTitle: 'App Settings',
        child: AnimatedScrollView(
            padding: EdgeInsets.symmetric(vertical: 8),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration:
                FadeInConfiguration(duration: Duration(seconds: 2)),
            children: [
              Obx(() => SettingItemWidget(
                leading: Icon(Icons.delete, color: Colors.red),
                title: "Delete Account",
                trailing: authController.isDeleteLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
                titleTextStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                onTap: authController.isDeleteLoading.value
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text(
                                'Are you sure you want to delete your account? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          authController.deleteAccount();
                        }
                      },
              )),
            ]));
  }
}
