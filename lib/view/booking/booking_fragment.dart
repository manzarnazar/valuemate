import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    return Scaffold(
      appBar: appBarWidget(
        "Bookings",
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
                        Text("Welcome Back!",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        16.height,
                        Text("Login to your account to continue",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        // Add the dummy data button here
                        16.height,

                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Login"),
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
                      return const Center(
                          child: Text('No bookings available.'));
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
                                          title: Text("All Statuses",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onTap: () =>
                                              Navigator.pop(context, 0),
                                        ),
                                        ..._constants.statuses
                                            .map((status) => ListTile(
                                                  title: Text(status.name,
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
                                          ? "All Statuses"
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
