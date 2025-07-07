import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/view/auth/login.dart';
import 'package:valuemate/res/colors/colors.dart';
import 'package:valuemate/view/dashboard/dashboard_screen.dart'; // Import your colors file

class WalkThroughModelClass {
  final String title;
  final String image;
  final String subTitle;

  WalkThroughModelClass({required this.title, required this.image, required this.subTitle});
}

class WalkThroughScreen extends StatefulWidget {
  @override
  _WalkThroughScreenState createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController pageController = PageController();
  int currentPosition = 0;
  List<WalkThroughModelClass> pages = [];

  @override
  void initState() {
    super.initState();
    initPages();
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });
  }

  void initPages() {
    pages = [
      WalkThroughModelClass(
        title: 'Choose Property Type',
        image: 'assets/images/onboard2.png',
        subTitle: 'Start by submitting a valuation request. Select the type of property you want valued, such as residential, commercial, or land.',
      ),
      WalkThroughModelClass(
        title: 'Choose Area and Location',
        image: 'assets/images/onboard1.png',
        subTitle: 'Enter the area and exact location of your property. This helps us find valuation companies familiar with your property region',
      ),
      WalkThroughModelClass(
        title: 'Select Valuation Company',
        image: 'assets/images/onboard4.png',
        subTitle: 'Browse the list of approved valuation companies. Choose the one that best fits your needs or preference.',
      ),
    ];
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: pages.length,
              onPageChanged: (value) {
                currentPosition = value;
                setState(() {});
              },
              itemBuilder: (context, index) {
                WalkThroughModelClass page = pages[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        page.image,
                        height: 200,
                        // color: Colors.deepPurple,
                      ),
                      40.height,
                      Text(
                        page.title,
                        style: boldTextStyle(size: 20, color: context.primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      16.height,
                      Text(
                        page.subTitle,
                        style: secondaryTextStyle(size: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          16.height,
          DotIndicator(
            pageController: pageController,
            pages: pages,
            indicatorColor: context.primaryColor,
            unselectedIndicatorColor: Colors.deepPurple.shade100,
            currentBoxShape: BoxShape.circle,
            boxShape: BoxShape.circle,
            dotSize: 8,
          ),
          40.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                  },
                  child: Text('Skip', style: boldTextStyle(color: context.primaryColor)),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (currentPosition == pages.length - 1) {
                      DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                    } else {
                      pageController.nextPage(duration: 500.milliseconds, curve: Curves.easeInOut);
                    }
                  },
                  child: Text(
                    currentPosition == pages.length - 1 ? 'Finish' : 'Next',
                    style: boldTextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}