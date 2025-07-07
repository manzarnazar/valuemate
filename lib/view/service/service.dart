import 'package:flutter/material.dart';
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
    // List faqs = serviceDetail['service_faq'] ?? [];

    return AppScaffold(
      appBarTitle: serviceDetail.name,
     
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.width(),
                  height: 200,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  child: Image.network(serviceDetail.file,fit: BoxFit.cover,),
                  // child: Center(
                  //   child: Icon(Icons.image, size: 80, color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                  // ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   children: [
                      //     Container(
                      //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      //       decoration: BoxDecoration(
                      //         color: primaryColor.withOpacity(0.1),
                      //         borderRadius: radius(4),
                      //       ),
                      //       child: Text(
                      //         serviceDetail['type'] ?? '',
                      //         style: secondaryTextStyle(size: 12, color: primaryColor),
                      //       ),
                      //     ),
                      //     Spacer(),
                      //   ],
                      // ),
                      12.height,
                      Text(serviceDetail.name ?? '', style: boldTextStyle(size: 20, color: context.iconColor)),
                      8.height,
                      // Row(
                      //   children: [
                      //     Text(
                      //       "₹${(serviceDetail['price'] ?? 0).toString()}",
                      //       style: boldTextStyle(size: 18, color: primaryColor),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                Container(
                  width: context.width(),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description", style: boldTextStyle(size: 16, color: context.iconColor)),
                      8.height,
                      Text(serviceDetail.description ?? '', style: secondaryTextStyle()),
                    ],
                  ),
                ),
                16.height,
                // if (faqs.isNotEmpty) ...[
                //   24.height,
                //   Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 16),
                //     child: Text("FAQ", style: boldTextStyle(size: 16, color: context.iconColor)),
                //   ),
                //   ListView.builder(
                //     itemCount: faqs.length,
                //     shrinkWrap: true,
                //     physics: NeverScrollableScrollPhysics(),
                //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     itemBuilder: (_, index) {
                //       final faq = faqs[index];
                //       return Container(
                //         margin: EdgeInsets.only(top: 15),
                //         decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(8)),
                //         child: ExpansionTile(
                //           title: Text(faq['question'] ?? '', style: boldTextStyle(color: context.iconColor)),
                //           children: [
                //             Padding(
                //               padding: EdgeInsets.all(12),
                //               child: Text(faq['answer'] ?? '', style: secondaryTextStyle()),
                //             ),
                //           ],
                //           initiallyExpanded: false,
                //           tilePadding: EdgeInsets.symmetric(horizontal: 12),
                //           childrenPadding: EdgeInsets.zero,
                //         ),
                //       );
                //     },
                //   ),
                // ],
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _dummyBookNow(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: radius(8)),
                  ),
                  child: Text("Request Valuation", style: boldTextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}