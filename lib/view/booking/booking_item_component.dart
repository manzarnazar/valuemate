import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
class BookingItemComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Container(
        padding: EdgeInsets.symmetric(horizontal:  8),
        margin: EdgeInsets.only(bottom: 5),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
      
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: context.primaryColor),
                                ),
                                child: Text(
                                  '#12345',
                                  style: TextStyle(
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  'Confirmed',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Premium Valuation Services',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).iconTheme.color
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '\$120',
                                  style: TextStyle(
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                         
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ).paddingAll(8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.cardColor,
                // border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Address:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ).expanded(flex: 2),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Text(
                          '123 Main St, Apt 4B, New York, NY 10001',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).iconTheme.color
                          ),
                        ),
                      ),
                    ],
                  ).paddingAll(8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Time:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ).expanded(flex: 2),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Text(
                          "May 15, 2023 at 2:00 PM",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).iconTheme.color
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 8, bottom: 8, right: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ).expanded(flex: 2),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Text(
                          "Paid via Credit Card",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 8, bottom: 8, right: 8),
                  // Column(
                  //   children: [
                  //     Divider(
                  //       color: Colors.grey[300],
                  //       height: 1,
                  //     ).paddingAll(8),
                  //     Padding(
                  //       padding: EdgeInsets.all(8),
                  //       child: Row(
                  //         children: [
                  //           CircleAvatar(
                  //             radius: 20,
                  //             backgroundColor: Colors.orange,
                  //             child: Icon(Icons.person, color: Colors.white),
                  //           ),
                  //           SizedBox(width: 16),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: [
                  //                 Row(
                  //                   children: [
                  //                     Text(
                  //                       "John Smith",
                  //                       style: TextStyle(
                  //                         fontWeight: FontWeight.bold,
                  //                         fontSize: 14,
                  //                       ),
                  //                     ),
                  //                     SizedBox(width: 4),
                  //                     Icon(
                  //                       Icons.verified,
                  //                       size: 14,
                  //                       color: Colors.green,
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 Text(
                  //                   "Service Provider",
                  //                   style: TextStyle(
                  //                     color: Colors.grey,
                  //                     fontSize: 12,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                
                ],
              ),
            ),
            SizedBox(height: 10,),
               Divider(
                        color: context.cardColor,
                        height: 2,
                      ).paddingAll(8),
          ],
        ),
    );
  }
}

extension WidgetExtension on Widget {
  Widget expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  Widget paddingAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}