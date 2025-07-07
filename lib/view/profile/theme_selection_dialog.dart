import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/theme_controller.dart';

class ThemeSelectionDaiLog extends StatefulWidget {
  @override
  ThemeSelectionDaiLogState createState() => ThemeSelectionDaiLogState();
}


class ThemeSelectionDaiLogState extends State<ThemeSelectionDaiLog> {
  final ThemeController themeController = Get.find<ThemeController>(); // ✅ FIXED

  List<String> themeModeList = ["Light", "Dark", "System default"];
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync("theme_mode_index", defaultValue: 0);
    setState(() {});
  }

  Future<void> _changeTheme(int index) async {
    await setValue("theme_mode_index", index);
    print(index);
    switch (index) {
      case 0:
        themeController.setTheme(false);
        break;
      case 1:
        themeController.setTheme(true);
        break;
      case 2:
        final brightness = MediaQuery.of(context).platformBrightness;
        themeController.setTheme(brightness == Brightness.dark);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ContextExtensions(context).width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            width: ContextExtensions(context).width(),
            decoration: boxDecorationDefault(
              color: context.primaryColor,
              borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Choose Theme", style: boldTextStyle(color: Colors.white)).flexible(),
                IconButton(
                  onPressed: () => finish(context),
                  icon: Icon(Icons.close, color: white),
                )
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 16),
            itemCount: themeModeList.length,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile(
                value: index,
                activeColor: context.primaryColor,
                groupValue: currentIndex,
                title: Text(
                  themeModeList[index],
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).iconTheme.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onChanged: (int? val) async {
                  if (val != null) {
                    await _changeTheme(val);
                    setState(() => currentIndex = val);
                    finish(context);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
