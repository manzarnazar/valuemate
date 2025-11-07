import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';

class CitySelectionScreen extends StatefulWidget {
  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final ConstantsController _constantsController = Get.find<ConstantsController>();

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredLocations = [];

  @override
  void initState() {
    super.initState();

    // Initialize filtered list from controller's locations (may be empty initially)
    _filteredLocations = _constantsController.locations.toList();

    // React to changes in the constants so the list updates when data is fetched
    ever(_constantsController.constants, (_) {
      setState(() {
        _filteredLocations = _constantsController.locations.toList();
        _applyFilter(_searchController.text);
      });
    });

    // Listen to search input and filter
    _searchController.addListener(() {
      _applyFilter(_searchController.text);
    });
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredLocations = _constantsController.locations.toList();
      } else {
        _filteredLocations = _constantsController.locations.where((loc) {
          final name = (loc.name ?? '').toString().toLowerCase();
          final nameAr = (loc.name_ar ?? '').toString().toLowerCase();
          return name.contains(q) || nameAr.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current language
    final currentLang = Get.locale?.languageCode ?? 'en';

    return AppScaffold(
      appBarTitle: "select_city".tr,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_city'.tr,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Text('no_bookings_available'.tr),
                  )
                : ListView.separated(
                    itemCount: _filteredLocations.length,
                    separatorBuilder: (context, index) => Divider(
                      color: context.cardColor,
                      height: 1,
                      thickness: 0.5,
                    ),
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];

                      // Choose Arabic or English name based on current language
                      final displayName = currentLang == 'ar'
                          ? location.name_ar
                          : location.name;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                        title: Text(
                          displayName.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.pop(context, location);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
