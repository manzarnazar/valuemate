import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/utlis/images.dart';
import 'package:valuemate/view/booking/booking_fragment.dart';
import 'package:valuemate/view/booking/property_form_screen.dart';
import 'package:valuemate/view/dashboard/fragment/dashboard_fragment.dart';
import 'package:valuemate/view/profile/profile_fragment.dart';


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
    height: 70, // Reduce height here (default is 80)
    child: NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: context.primaryColor.withAlpha(5),
        indicatorColor: context.primaryColor.withAlpha(25),
        labelTextStyle: MaterialStateProperty.all(
          primaryTextStyle(size: 10, color: context.iconColor), // smaller font
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        destinations: [
          NavigationDestination(
            icon: Image.asset(ic_edit_square, color: context.iconColor, height: 25, width: 25),
            selectedIcon: Image.asset(ic_edit_square, color: context.primaryColor, height: 25, width: 25),
            label: 'Request',
          ),
          NavigationDestination(
            icon: Image.asset(ic_home, color: context.iconColor, height: 25, width: 25), // smaller icon
            selectedIcon: Image.asset(ic_home, color: context.primaryColor, height: 25, width: 25),
            label: 'Companies',
          ),
          NavigationDestination(
            icon: Image.asset(ic_ticket, color: context.iconColor, height: 25, width: 25),
            selectedIcon: Image.asset(ic_ticket, color: context.primaryColor, height: 25, width: 25),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Image.asset(ic_category, color: context.iconColor, height: 25, width: 25),
            selectedIcon: Image.asset(ic_profile2, color: context.primaryColor, height: 25, width: 25),
            label: 'Menu',
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

    );
  }
}