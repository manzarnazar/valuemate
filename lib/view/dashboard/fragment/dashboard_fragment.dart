import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/view/dashboard/components/citySelection.dart';
// import 'package:valuemate/view/dashboard/components/property_type_component.dart';
import 'package:valuemate/view/dashboard/components/service_component.dart';
import 'package:valuemate/view/dashboard/components/slider_location_component.dart';
import 'package:valuemate/view/dashboard/fragment/dashboard_shimmer.dart';
import 'package:valuemate/view/service/service.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  final ConstantsController _constantsController =
      Get.find<ConstantsController>();

  String? selectedCityName;
  int? selectedCityKey;

  void _navigateToCitySelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitySelectionScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCityName = result.name;
        selectedCityKey = result.id;
        print(selectedCityKey);
      });
    }
  }

  List<String> urls() {
    return _constantsController.banner
        .map<String>((item) => item.imageUrl.toString())
        .toList();
  }

  // final List<Map<String, dynamic>> types = const [
  //   {"label": "All", "icon": Icons.all_inclusive},
  //   {"label": "Houses", "icon": Icons.home},
  //   {"label": "Apartments", "icon": Icons.apartment},
  //   {"label": "Residential Land", "icon": Icons.terrain},
  //   {"label": "Agricultural Land", "icon": Icons.agriculture},
  //   {
  //     "label": "Industrial Land",
  //     "icon": Icons.factory
  //   }, // factory icon from Flutter 3.7+
  //   {"label": "Commercial Land", "icon": Icons.business},
  //   {"label": "Commercial Shops", "icon": Icons.store},
  //   {"label": "Commercial Buildings", "icon": Icons.apartment},
  //   {"label": "Residential Complexes", "icon": Icons.maps_home_work},
  //   {"label": "Commercial Complexes", "icon": Icons.location_city},
  //   {"label": "Warehouses", "icon": Icons.warehouse},
  //   {"label": "Factories", "icon": Icons.factory},
  // ];

  PageController sliderPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;
  String? selectedPropertyType;
  bool _isLoading = true; // Add this state variable

  @override
  void initState() {
    super.initState();
    selectedPropertyType = "All";

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    if (urls().length >= 2) {
      _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
        if (_currentPage < urls().length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        sliderPageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 950),
          curve: Curves.easeOutQuart,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    sliderPageController.dispose();
    super.dispose();
  }

  void handlePropertyTypeSelected(String type) {
    setState(() {
      selectedPropertyType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: _isLoading
          ? DashboardShimmer()
          : AnimatedScrollView(
              // Your existing content

              physics: AlwaysScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration:
                  FadeInConfiguration(duration: Duration(seconds: 2)),
              onSwipeRefresh: () async {},
              children: [
                CustomSliderWithLocation(
                  imageUrls: urls(),
                  currentLocation: selectedCityName ?? 'Select Location',
                  onLocationTap: () {
                    _navigateToCitySelection();
                  },
                ),
                40.height,
                // Row(
                //   children: [
                //     Text("Property Type",
                //         style: boldTextStyle(
                //           size: 14,
                //           color: Theme.of(context).iconTheme?.color,
                //         )).paddingSymmetric(horizontal: 16)
                //   ],
                // ),
                // PropertyTypesWidget(
                //   types: types,
                //   selectedType: selectedPropertyType,
                //   onTypeSelected: handlePropertyTypeSelected,
                // ),
                // 20.height,
                Row(
                  children: [
                    Text("Companies",
                        style: boldTextStyle(
                          size: 14,
                          color: Theme.of(context).iconTheme?.color,
                        )).paddingSymmetric(horizontal: 16)
                  ],
                ),
                15.height,
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  // children: filteredServices.map((service) {
                  children: _constantsController.companies.map((service) {
                    return GestureDetector(
                      onTap: () {
                        ServiceDetailScreen(serviceDetail: service)
                            .launch(context);
                      },
                      child: ServiceComponent(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        serviceData: service,
                      ),
                    );
                  }).toList(),
                ).paddingSymmetric(horizontal: 16),
                10.height,
              ],
            ),
    );
  }
}
