import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';

class CitySelectionScreen extends StatelessWidget {
      final ConstantsController _constantsController = Get.put(ConstantsController());

  final List<Map<String, String>> cities = [
    {'key': 'muscat', 'name': 'Muscat'},
    {'key': 'salalah', 'name': 'Salalah'},
    {'key': 'sohar', 'name': 'Sohar'},
    {'key': 'sur', 'name': 'Sur'},
    {'key': 'nizwa', 'name': 'Nizwa'},
    {'key': 'ibri', 'name': 'Ibri'},
    {'key': 'saham', 'name': 'Saham'},
    {'key': 'barka', 'name': 'Barka'},
    {'key': 'rustaq', 'name': 'Al Rustaq'},
    {'key': 'buraimi', 'name': 'Al Buraimi'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: "Select a City",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                // border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // Add search functionality here
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _constantsController.locations.length,
              separatorBuilder: (context, index) => Divider(
                color: context.cardColor,
                height: 1,
                thickness: 0.5,
              ),
              itemBuilder: (context, index) {
                final locations = _constantsController.locations;
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                  title: Text(
                    locations[index].name.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context, locations[index]);
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
