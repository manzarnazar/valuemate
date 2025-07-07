import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/view/profile/theme_selection_dialog.dart';
class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return 
      AppScaffold(appBarTitle: 'App Settings', 
      child:  AnimatedScrollView(
        padding: EdgeInsets.symmetric(vertical: 8),
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
              SettingItemWidget(
              leading: Icon(Icons.lock),
              title: "Change Password",
              trailing: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
              titleTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).iconTheme.color ),
              onTap: () {
               
              },
            ),
             SettingItemWidget(
              leading: Icon(Icons.dark_mode),
              title: "Choose Theme",
              trailing: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
              titleTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).iconTheme.color, ),
             onTap: () async {
              await showInDialog(
                context,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
            ),
        ]
    )
    );
  }
}
