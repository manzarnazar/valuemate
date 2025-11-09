import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/res/routes/routes_name.dart';
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
    return AppScaffold(
        appBarTitle: 'app_name'.tr,
        child: AnimatedScrollView(
            padding: EdgeInsets.symmetric(vertical: 8),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration:
                FadeInConfiguration(duration: Duration(seconds: 2)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text('language'.tr + ': ', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(width: 16),
                    DropdownButton<Locale>(
                      value: Get.locale?.languageCode == 'ar'
                          ? const Locale('ar', 'SA')
                          : const Locale('en', 'US'),
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en', 'US'),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale('ar', 'SA'),
                          child: Text('العربية'),
                        ),
                      ],
                      onChanged: (locale) {
                        if (locale != null) {
                          Get.updateLocale(locale);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.toNamed(RouteName.supportChat);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'support_chat'.tr,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).iconTheme.color),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => SettingItemWidget(
                leading: Icon(Icons.delete, color: Colors.red),
                title: "delete_account".tr,
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
                            title: Text('confirm_delete'.tr),
                            content: Text(
                                'confirm_delete_content'.tr),
                            actions: [
                              TextButton(
                                child: Text('cancel'.tr),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: Text('delete'.tr,
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
