import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/view/booking/booking_item_component.dart';

class BookingFragment extends StatefulWidget {
  const BookingFragment({super.key});

  @override
  State<BookingFragment> createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Bookings",
        textColor: white,
        showBack: false,
        textSize: 18,
        elevation: 3.0,
        color: context.primaryColor,
     
      ),
      // extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: AnimatedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          onSwipeRefresh: () async {},
          children: [
            SizedBox(height: context.statusBarHeight),
            Wrap(
              // spacing: 16,
              runSpacing: 16,
              children: List.generate(6, (index) {
                return  BookingItemComponent();
              }),
            ),
              
          ],
        ),
      ),
    );
  }
}