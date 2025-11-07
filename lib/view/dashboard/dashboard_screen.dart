import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';
import 'package:valuemate/utlis/images.dart';
import 'package:valuemate/view/booking/booking_fragment.dart';
import 'package:valuemate/view/booking/property_form_screen.dart';
import 'package:valuemate/view/dashboard/fragment/dashboard_fragment.dart';
import 'package:valuemate/view/profile/profile_fragment.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0}); // Default to 0

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.initialIndex);
    return Scaffold(
      body: [
        PropertyForm(),
        DashboardFragment(),
        BookingFragment(),
        ProfileFragment(),
      ][currentIndex],
      bottomNavigationBar: Blur(
        blur: 30,
        borderRadius: radius(0),
        child: SizedBox(
          height: 80, // Reduce height here (default is 80)
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: context.primaryColor.withAlpha(5),
              indicatorColor: context.primaryColor.withAlpha(20),
              labelTextStyle: MaterialStateProperty.all(
                        primaryTextStyle(
                            size: 10, color: Theme.of(context).iconTheme.color), // smaller font
              ),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
        child: NavigationBar(
                selectedIndex: currentIndex,
                destinations: [
                NavigationDestination(
                  icon: Image.asset(ic_edit_square,
            color: Theme.of(context).iconTheme.color, height: 20, width: 20),
          selectedIcon: Image.asset(ic_edit_square,
            color: context.primaryColor, height: 20, width: 20),
                  label: 'request'.tr,
                ),
                NavigationDestination(
                  icon: Image.asset(ic_home,
            color: Theme.of(context).iconTheme.color,
                      height: 20,
                      width: 20), // smaller icon
          selectedIcon: Image.asset(ic_home,
            color: context.primaryColor, height: 20, width: 20),
                  label: 'companies'.tr,
                ),
                NavigationDestination(
                  icon: Image.asset(ic_ticket,
            color: Theme.of(context).iconTheme.color, height: 20, width: 20),
          selectedIcon: Image.asset(ic_ticket,
            color: context.primaryColor, height: 20, width: 20),
                  label: 'bookings'.tr,
                ),
                NavigationDestination(
                  icon: Image.asset(ic_category,
            color: Theme.of(context).iconTheme.color, height: 20, width: 20),
          selectedIcon: Image.asset(ic_profile2,
            color: context.primaryColor, height: 20, width: 20),
                  label: 'menu'.tr,
                ),
              ],
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    ));
  }
}
