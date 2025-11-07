import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';
import 'package:valuemate/res/colors/colors.dart';
import 'package:valuemate/view/booking/property_form_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Company serviceDetail;

  const ServiceDetailScreen({
    super.key,
    required this.serviceDetail,
  });

  void _dummyBookNow(BuildContext context) {
    try {
      PropertyForm(
        preSelected: true,
        selectedCompany: serviceDetail,
      ).launch(context);
    } catch (e) {
      toast("Error opening booking form: ${e.toString()}");
      debugPrint("Booking form error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get current language
    final currentLang = Get.locale?.languageCode ?? 'en';

    // ✅ Choose text based on language
    final displayName =
        currentLang == 'ar' ? serviceDetail.name_ar ?? '' : serviceDetail.name ?? '';
    final displayDescription = currentLang == 'ar'
        ? serviceDetail.description_ar ?? ''
        : serviceDetail.description ?? '';

    return AppScaffold(
      appBarTitle: displayName,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  child: Image.network(
                    serviceDetail.file,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      12.height,
                      Text(
                        displayName,
                        style: boldTextStyle(size: 20, color: Theme.of(context).iconTheme.color),
                      ),
                      8.height,
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.cardColor,
                    borderRadius: radius(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("description".tr,
                          style: boldTextStyle(size: 16, color: Theme.of(context).iconTheme.color)),
                      8.height,
                      Text(
                        displayDescription,
                        style: secondaryTextStyle(),
                      ),
                    ],
                  ),
                ),
                16.height,
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _dummyBookNow(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: radius(8)),
                  ),
                  child: Text(
                    "request_valuation".tr,
                    style: boldTextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
