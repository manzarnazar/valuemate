import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';
import 'package:valuemate/models/history_model/history.dart';
import 'package:valuemate/view/paymentScreen/PaymentWebview.dart';
import 'package:valuemate/view_models/services/contorller/auth/user_prefrence_view_model.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';
import 'package:valuemate/view_models/valuation_request_model/valuation_request_view_model.dart';

class BookingItemComponent extends StatefulWidget {
  final HistoryModel booking;

  const BookingItemComponent({super.key, required this.booking});

  @override
  State<BookingItemComponent> createState() => _BookingItemComponentState();
}

class _BookingItemComponentState extends State<BookingItemComponent> {
  final ConstantsController _constantsController =
      Get.find<ConstantsController>();

  Setting get currency => _constantsController.settings.firstWhere(
        (setting) => setting.key == "currency",
      );

  final ValuationViewModel _requestController = Get.put(ValuationViewModel());
  String? token;

  @override
  void initState() {
    super.initState();

    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tok = prefs.getString('token');

      if (mounted) {
        setState(() {
          token = tok;
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Login Again Or Restart the app");
      print("Error loading token: $e");
    }
  }

  void _showPaymentMethodBottomSheet() async {
    int? selectedPaymentMethodId;
    final user = await UserPreference().getUser();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "select_payment_method".tr,
                  style: boldTextStyle(
                      size: 20, color: Theme.of(context).iconTheme.color),
                ),
                SizedBox(height: 20),
                Obx(() {
                  if (_constantsController.paymentMethods.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "no_payment_methods".tr,
                        style: secondaryTextStyle(),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          _constantsController.paymentMethods.map((method) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: selectedPaymentMethodId == method.id
                                ? context.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedPaymentMethodId == method.id
                                  ? context.primaryColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              method.name,
                              style: primaryTextStyle(
                                weight: selectedPaymentMethodId == method.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selectedPaymentMethodId == method.id
                                    ? context.primaryColor
                                    : Theme.of(context).iconTheme.color,
                              ),
                            ),
                            onTap: () {
                              setModalState(() {
                                selectedPaymentMethodId = method.id;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
                SizedBox(height: 20),
                Obx(() {
                  return _requestController.isLoading.value
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (selectedPaymentMethodId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('please_select_payment'.tr)),
                              );
                              return;
                            }

                            if (user == null || token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('some_required_missing'.tr)),
                              );
                              return;
                            }

                            if (selectedPaymentMethodId == 1) {
                              try {
                                _requestController.isLoading.value = true;
                                final paymentResponse =
                                    await _requestController.initiatePayment(
                                  valuationRequestId: widget.booking.id,
                                  paymentMethodId: selectedPaymentMethodId!,
                                  token: token!,
                                );

                                print(paymentResponse);

                                if (paymentResponse['status'] == true &&
                                    paymentResponse['data']?['url'] != null) {
                                  final checkoutUrl =
                                      paymentResponse['data']['url'];
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WebViewPage(url: checkoutUrl),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            paymentResponse['message'] ??
                                                'payment_initiation_failed'
                                                    .tr)),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${e.toString()}')),
                                );
                              } finally {
                                _requestController.isLoading.value = false;
                              }
                            } else if (selectedPaymentMethodId != 1) {
                              Get.snackbar(
                                  'coming_soon'.tr, 'work_in_progress'.tr);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "proceed_to_payment".tr,
                            style: boldTextStyle(color: Colors.white),
                          ),
                        );
                }),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBookingDetailsDialog(BuildContext context) {
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("booking_details".tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogRow("company_label".tr, widget.booking.companyName),
              _dialogRow("user_label".tr, widget.booking.userName),
              _dialogRow("property_type_label".tr, widget.booking.propertyType),
              _dialogRow(
                  "service_type_label_label".tr, widget.booking.serviceType),
              _dialogRow("request_type_label".tr, widget.booking.requestType),
              _dialogRow("location_label".tr, widget.booking.location),
              _dialogRow("pricing_label".tr, widget.booking.servicePricing),
              _dialogRow("area_label_label".tr, widget.booking.area),
              _dialogRow("amount_label".tr,
                  "${widget.booking.totalAmount} ${currency.value}"),
              _dialogRow("status_label".tr, widget.booking.status),
              _dialogRow("reference_label".tr, widget.booking.reference),
              _dialogRow("date_label".tr, widget.booking.createdAtDate),
              _dialogRow("time_label".tr, widget.booking.createdAtTime),
              _dialogRow("payment_label".tr, widget.booking.paymentStatus),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("close".tr),
          ),
          if (widget.booking.status_id == 1 || widget.booking.status_id == 2)
            ElevatedButton(
              onPressed: () {
                // Navigator.pop(context);
                _showPaymentMethodBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // Button color
                foregroundColor: Colors.white, // Text/icon color
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                textStyle: const TextStyle(
                  fontSize: 16,
                  // fontWeight: FontWeight.w600,
                ),
              ),
              child: Text("pay_now".tr),
            ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
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
                  child: Icon(Icons.home_work_outlined, color: Colors.white),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.primaryColor),
                              ),
                              child: Text(
                                '#${widget.booking.id}',
                                style: TextStyle(
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                widget.booking.status,
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
                      widget.booking.serviceType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.booking.totalAmount} ${currency.value}',
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
          ).paddingAll(8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowItem(
                    '${'address_label'.tr}:', widget.booking.location, context),
                _rowItem(
                    '${'date_time_label'.tr}:',
                    '${widget.booking.createdAtDate} at ${widget.booking.createdAtTime}',
                    context),
                _rowItem('${'payment_status_label'.tr}:',
                    widget.booking.paymentStatus, context),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      _showBookingDetailsDialog(
                        context,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      textStyle: TextStyle(fontSize: 14),
                      minimumSize:
                          Size(0, 0), // removes default min constraints
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // reduces tap area
                    ),
                    child: Text(
                      (widget.booking.status_id == 1 ||
                              widget.booking.status_id == 2)
                          ? 'view_pay_now'.tr
                          : 'view'.tr,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(
            color: context.cardColor,
            height: 2,
          ).paddingAll(8),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ],
    ).paddingOnly(left: 8, bottom: 8, right: 8);
  }
}
