import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/res/routes/routes_name.dart';
import 'package:valuemate/view/booking/booking_item_component.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';
import 'package:valuemate/view_models/services/contorller/history/history_view_model.dart';

class BookingFragment extends StatefulWidget {
  const BookingFragment({super.key});

  @override
  State<BookingFragment> createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  final HistoryViewModel _history = Get.put(HistoryViewModel());
  String? token;
  bool _isTokenChecked = false;
  final ConstantsController _constants = Get.find<ConstantsController>();

  @override
  void initState() {
    super.initState();
    _checkTokenAndLoadData();
  }

  Future<void> _checkTokenAndLoadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {
      _history.getRequests();
    }

    _isTokenChecked = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
        final currentLang = Get.locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: appBarWidget(
        "bookings".tr,
        textColor: white,
        showBack: false,
        textSize: 18,
        elevation: 3.0,
        color: context.primaryColor,
      ),
      body: SafeArea(
        top: false,
        child: !_isTokenChecked
            ? const Center(child: CircularProgressIndicator())
            : token == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("welcome_back".tr,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).iconTheme.color)),
                        16.height,
                        Text("login_to_continue".tr,
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        16.height,
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed(RouteName.loginView);
                                  },
                                  child: Text("login".tr),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Obx(() {
                    if (_history.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_history.error.isNotEmpty) {
                      return Center(child: Text(_history.error.value));
                    }

                    if (_history.requests.isEmpty) {
                      return Center(child: Text('no_bookings_available'.tr,style: TextStyle(color: Theme.of(context).iconTheme.color),));
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Obx(() {
                            return InkWell(
                              onTap: () async {
                                final selected =
                                    await showModalBottomSheet<int>(
                                  context: context,
                                  backgroundColor: context.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  builder: (context) {
                                    return ListView(
                                      shrinkWrap: true,
                                      children: [
                                        ListTile(
                                          title: Text("all_statuses".tr,
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onTap: () =>
                                              Navigator.pop(context, 0),
                                        ),
                                        ..._constants.statuses
                                            .map((status) => ListTile(
                                                  title: Text(currentLang == "en" ? status.name : status.name_ar,
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  onTap: () => Navigator.pop(
                                                      context, status.id),
                                                )),
                                      ],
                                    );
                                  },
                                );

                                if (selected != null) {
                                  _history.selectedStatusId.value = selected;
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: context.primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _history.selectedStatusId.value == 0
                                          ? "all_statuses".tr
                                          : _constants.statuses
                                              .firstWhere((s) =>
                                                  s.id ==
                                                  _history
                                                      .selectedStatusId.value)
                                              .name,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        Expanded(
                          child: AnimatedScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            listAnimationType: ListAnimationType.FadeIn,
                            fadeInConfiguration: FadeInConfiguration(
                                duration: Duration(seconds: 2)),
                            onSwipeRefresh: () async {
                              await _history.getRequests();
                            },
                            children: [
                              Wrap(
                                runSpacing: 16,
                                children: _history.filteredRequests
                                    .map((booking) =>
                                        BookingItemComponent(booking: booking))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
      ),
    );
  }
}
