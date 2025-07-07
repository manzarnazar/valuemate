import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/components/base_scaffold_widget.dart';
import 'package:valuemate/view/dashboard/components/citySelection.dart';
import 'package:valuemate/view/dashboard/components/property_type_component.dart';
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
  final List<String> imageList = [
    'assets/images/slider1.png',
    'assets/images/slider2.png',
    'assets/images/slider3.png',
  ];

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

  final List<Map<String, dynamic>> types = const [
    {"label": "All", "icon": Icons.all_inclusive},
    {"label": "Houses", "icon": Icons.home},
    {"label": "Apartments", "icon": Icons.apartment},
    {"label": "Residential Land", "icon": Icons.terrain},
    {"label": "Agricultural Land", "icon": Icons.agriculture},
    {"label": "Industrial Land", "icon": Icons.factory}, // factory icon from Flutter 3.7+
    {"label": "Commercial Land", "icon": Icons.business},
    {"label": "Commercial Shops", "icon": Icons.store},
    {"label": "Commercial Buildings", "icon": Icons.apartment},
    {"label": "Residential Complexes", "icon": Icons.maps_home_work},
    {"label": "Commercial Complexes", "icon": Icons.location_city},
    {"label": "Warehouses", "icon": Icons.warehouse},
    {"label": "Factories", "icon": Icons.factory},
  ];
  final List<Map<String, dynamic>> services = [
    // House services
    {
      'name': 'Standard Valuation',
      'price': 59.99,
      'type': 'house',
      'imageUrl': 'assets/images/house1.jpg',
      'city': 'Muscat',
      'description':
          'Professional valuation service for standard residential properties, providing accurate market value assessment.',
      'service_faq': [
        {
          'question': 'What factors are considered in the valuation?',
          'answer':
              'We consider location, property size, age, condition, and recent sales of comparable properties.'
        },
        {
          'question': 'How long does the valuation process take?',
          'answer': 'Typically 1-2 business days after the physical inspection.'
        },
        {
          'question': 'Do I need to prepare any documents?',
          'answer':
              'Yes, please have property deeds, any renovation records, and utility bills ready.'
        },
        {
          'question': 'Is the valuation report legally binding?',
          'answer':
              'It can be used for reference but may need certification for legal purposes.'
        },
        {
          'question': 'Do you value properties with tenants?',
          'answer':
              'Yes, but access to all areas must be arranged with the tenant.'
        }
      ],
    },
    {
      'name': 'Premium Valuation',
      'price': 89.99,
      'type': 'house',
      'imageUrl': 'assets/images/house2.jpg',
      'city': 'Salalah',
      'description':
          'Comprehensive valuation with detailed analysis, perfect for high-value properties or complex cases.',
      'service_faq': [
        {
          'question': 'What makes this different from standard valuation?',
          'answer':
              'Includes detailed comparable analysis, future value projection, and renovation impact assessment.'
        },
        {
          'question': 'Can this be used for insurance purposes?',
          'answer':
              'Yes, this level of valuation is accepted by most insurance companies.'
        },
        {
          'question': 'Do you provide advice on increasing property value?',
          'answer':
              'Yes, our premium report includes recommendations for value enhancement.'
        },
        {
          'question': 'How current are your market comparisons?',
          'answer': 'We use data from the last 3 months to ensure accuracy.'
        },
        {
          'question': 'Is weekend inspection available?',
          'answer': 'Yes, by prior arrangement for an additional fee.'
        }
      ],
    },

    // Villa services
    {
      'name': 'Luxury Property Appraisal',
      'price': 75.50,
      'type': 'villa',
      'imageUrl': 'assets/images/villa1.jpg',
      'city': 'Sohar',
      'description':
          'Specialized appraisal for luxury villas, considering premium amenities and exclusive locations.',
      'service_faq': [
        {
          'question':
              'How do you value unique features like pools or smart homes?',
          'answer':
              'We use premium valuation matrices for luxury features and smart technology.'
        },
        {
          'question': 'Do you consider view quality in valuation?',
          'answer':
              'Yes, views are quantitatively assessed in our luxury valuations.'
        },
        {
          'question': 'What security features affect value?',
          'answer':
              'Gated communities, security systems, and privacy features all contribute positively.'
        },
        {
          'question': 'How often should luxury properties be revalued?',
          'answer':
              'We recommend every 12-18 months due to market fluctuations.'
        },
        {
          'question': 'Do you value furnished vs unfurnished differently?',
          'answer':
              'Only if the furnishings are high-end and included in the sale.'
        }
      ],
    },
    {
      'name': 'High-End Valuation',
      'price': 99.00,
      'type': 'villa',
      'imageUrl': 'assets/images/villa2.jpg',
      'city': 'Nizwa',
      'description':
          'Expert valuation for premium villas with detailed market analysis and investment potential.',
      'service_faq': [
        {
          'question': 'Do you provide international market comparisons?',
          'answer':
              'Yes, for high-end properties we include relevant global market trends.'
        },
        {
          'question': 'How do you assess architectural uniqueness?',
          'answer':
              'Our specialists evaluate design quality and architectural significance.'
        },
        {
          'question': 'What about properties with historical value?',
          'answer':
              'These require special assessment which may take additional time.'
        },
        {
          'question': 'Can you value properties under construction?',
          'answer': 'Yes, based on plans, specifications, and current progress.'
        },
        {
          'question': 'Do you consider potential rental income?',
          'answer':
              'Yes, for investment properties we include income potential analysis.'
        }
      ],
    },
    {
      'name': 'Luxury Property Appraisal',
      'price': 75.50,
      'type': 'villa',
      'imageUrl': 'assets/images/villa1.jpg',
      'city': 'Sohar',
      'description':
          'Specialized appraisal for luxury villas, considering premium amenities and exclusive locations.',
      'service_faq': [
        {
          'question':
              'How do you value unique features like pools or smart homes?',
          'answer':
              'We use premium valuation matrices for luxury features and smart technology.'
        },
        {
          'question': 'Do you consider view quality in valuation?',
          'answer':
              'Yes, views are quantitatively assessed in our luxury valuations.'
        },
        {
          'question': 'What security features affect value?',
          'answer':
              'Gated communities, security systems, and privacy features all contribute positively.'
        },
        {
          'question': 'How often should luxury properties be revalued?',
          'answer':
              'We recommend every 12-18 months due to market fluctuations.'
        },
        {
          'question': 'Do you value furnished vs unfurnished differently?',
          'answer':
              'Only if the furnishings are high-end and included in the sale.'
        }
      ],
    },
    {
      'name': 'High-End Valuation',
      'price': 99.00,
      'type': 'villa',
      'imageUrl': 'assets/images/villa2.jpg',
      'city': 'Nizwa',
      'description':
          'Expert valuation for premium villas with detailed market analysis and investment potential.',
      'service_faq': [
        {
          'question': 'Do you provide international market comparisons?',
          'answer':
              'Yes, for high-end properties we include relevant global market trends.'
        },
        {
          'question': 'How do you assess architectural uniqueness?',
          'answer':
              'Our specialists evaluate design quality and architectural significance.'
        },
        {
          'question': 'What about properties with historical value?',
          'answer':
              'These require special assessment which may take additional time.'
        },
        {
          'question': 'Can you value properties under construction?',
          'answer': 'Yes, based on plans, specifications, and current progress.'
        },
        {
          'question': 'Do you consider potential rental income?',
          'answer':
              'Yes, for investment properties we include income potential analysis.'
        }
      ],
    },

    // Land services
    {
      'name': 'Land Parcel Valuation',
      'price': 150.00,
      'type': 'land',
      'imageUrl': 'assets/images/land1.jpg',
      'city': 'Ibri',
      'description':
          'Accurate valuation of undeveloped land considering zoning, topography, and development potential.',
      'service_faq': [
        {
          'question': 'What zoning information do you need?',
          'answer':
              'Please provide any municipal zoning documents or planning permissions.'
        },
        {
          'question': 'How do you value land with access issues?',
          'answer': 'Access limitations are factored into our valuation models.'
        },
        {
          'question': 'Do you consider future infrastructure projects?',
          'answer':
              'Yes, known future developments are included in our assessment.'
        },
        {
          'question': 'How does topography affect value?',
          'answer':
              'Steep slopes or rocky terrain may reduce value, while flat land is preferred.'
        },
        {
          'question': 'What about agricultural land valuation?',
          'answer':
              'This requires special assessment of soil quality and water rights.'
        }
      ],
    },
    {
      'name': 'Development Land Appraisal',
      'price': 30.00,
      'type': 'land',
      'imageUrl': 'assets/images/land3.jpg',
      'city': 'Rustaq',
      'description':
          'Professional assessment of land development potential including feasibility studies.',
      'service_faq': [
        {
          'question': 'What development factors do you consider?',
          'answer':
              'We analyze zoning, infrastructure access, soil conditions, and market demand.'
        },
        {
          'question': 'Do you provide density recommendations?',
          'answer':
              'Yes, our report includes optimal development density analysis.'
        },
        {
          'question': 'How current are your construction cost estimates?',
          'answer': 'We update our cost databases quarterly.'
        },
        {
          'question': 'Can you assess environmental constraints?',
          'answer':
              'Yes, we identify any environmental limitations or requirements.'
        },
        {
          'question': 'Do you consider phasing potential for large parcels?',
          'answer': 'Yes, we can recommend development phasing strategies.'
        }
      ],
    },
    {
      'name': 'Land Parcel Valuation',
      'price': 150.00,
      'type': 'land',
      'imageUrl': 'assets/images/land1.jpg',
      'city': 'Ibri',
      'description':
          'Accurate valuation of undeveloped land considering zoning, topography, and development potential.',
      'service_faq': [
        {
          'question': 'What zoning information do you need?',
          'answer':
              'Please provide any municipal zoning documents or planning permissions.'
        },
        {
          'question': 'How do you value land with access issues?',
          'answer': 'Access limitations are factored into our valuation models.'
        },
        {
          'question': 'Do you consider future infrastructure projects?',
          'answer':
              'Yes, known future developments are included in our assessment.'
        },
        {
          'question': 'How does topography affect value?',
          'answer':
              'Steep slopes or rocky terrain may reduce value, while flat land is preferred.'
        },
        {
          'question': 'What about agricultural land valuation?',
          'answer':
              'This requires special assessment of soil quality and water rights.'
        }
      ],
    },
    {
      'name': 'Development Land Appraisal',
      'price': 30.00,
      'type': 'land',
      'imageUrl': 'assets/images/land3.jpg',
      'city': 'Rustaq',
      'description':
          'Professional assessment of land development potential including feasibility studies.',
      'service_faq': [
        {
          'question': 'What development factors do you consider?',
          'answer':
              'We analyze zoning, infrastructure access, soil conditions, and market demand.'
        },
        {
          'question': 'Do you provide density recommendations?',
          'answer':
              'Yes, our report includes optimal development density analysis.'
        },
        {
          'question': 'How current are your construction cost estimates?',
          'answer': 'We update our cost databases quarterly.'
        },
        {
          'question': 'Can you assess environmental constraints?',
          'answer':
              'Yes, we identify any environmental limitations or requirements.'
        },
        {
          'question': 'Do you consider phasing potential for large parcels?',
          'answer': 'Yes, we can recommend development phasing strategies.'
        }
      ],
    },

    // Apartment services
    {
      'name': 'Condominium Valuation',
      'price': 299.99,
      'type': 'apartment',
      'imageUrl': 'assets/images/apartment1.jpg',
      'city': 'Muscat',
      'description':
          'Specialized valuation for condominium units including common area assessments.',
      'service_faq': [
        {
          'question': 'How are building amenities factored in?',
          'answer':
              'We proportionally allocate the value of shared amenities to each unit.'
        },
        {
          'question': 'Do you consider maintenance fees?',
          'answer':
              'Yes, we analyze how fees affect net value and marketability.'
        },
        {
          'question': 'What about special assessments?',
          'answer':
              'Pending or recent special assessments are deducted from the valuation.'
        },
        {
          'question': 'How do you value parking spaces?',
          'answer': 'Separately if deeded, or included if assigned.'
        },
        {
          'question': 'Do you consider rental restrictions?',
          'answer': 'Yes, these can significantly impact investment value.'
        }
      ],
    },
    {
      'name': 'Apartment Complex Appraisal',
      'price': 499.99,
      'type': 'apartment',
      'imageUrl': 'assets/images/apartment2.png',
      'city': 'Salalah',
      'description':
          'Complete valuation of multi-unit apartment buildings including income approach analysis.',
      'service_faq': [
        {
          'question': 'What valuation methods do you use?',
          'answer': 'We apply income, cost, and sales comparison approaches.'
        },
        {
          'question': 'How do you verify rental income?',
          'answer': 'We request 2-3 years of rent rolls and expense statements.'
        },
        {
          'question': 'Do you consider vacancy rates?',
          'answer': 'Yes, we analyze historical and market vacancy data.'
        },
        {
          'question': 'What about deferred maintenance?',
          'answer': 'We identify and quantify needed repairs in our valuation.'
        },
        {
          'question':
              'How do you value commercial spaces in mixed-use buildings?',
          'answer':
              'These are valued separately using commercial valuation methods.'
        }
      ],
    },
    {
      'name': 'Condominium Valuation',
      'price': 299.99,
      'type': 'apartment',
      'imageUrl': 'assets/images/apartment1.jpg',
      'city': 'Muscat',
      'description':
          'Specialized valuation for condominium units including common area assessments.',
      'service_faq': [
        {
          'question': 'How are building amenities factored in?',
          'answer':
              'We proportionally allocate the value of shared amenities to each unit.'
        },
        {
          'question': 'Do you consider maintenance fees?',
          'answer':
              'Yes, we analyze how fees affect net value and marketability.'
        },
        {
          'question': 'What about special assessments?',
          'answer':
              'Pending or recent special assessments are deducted from the valuation.'
        },
        {
          'question': 'How do you value parking spaces?',
          'answer': 'Separately if deeded, or included if assigned.'
        },
        {
          'question': 'Do you consider rental restrictions?',
          'answer': 'Yes, these can significantly impact investment value.'
        }
      ],
    },
    {
      'name': 'Apartment Complex Appraisal',
      'price': 499.99,
      'type': 'apartment',
      'imageUrl': 'assets/images/apartment2.png',
      'city': 'Salalah',
      'description':
          'Complete valuation of multi-unit apartment buildings including income approach analysis.',
      'service_faq': [
        {
          'question': 'What valuation methods do you use?',
          'answer': 'We apply income, cost, and sales comparison approaches.'
        },
        {
          'question': 'How do you verify rental income?',
          'answer': 'We request 2-3 years of rent rolls and expense statements.'
        },
        {
          'question': 'Do you consider vacancy rates?',
          'answer': 'Yes, we analyze historical and market vacancy data.'
        },
        {
          'question': 'What about deferred maintenance?',
          'answer': 'We identify and quantify needed repairs in our valuation.'
        },
        {
          'question':
              'How do you value commercial spaces in mixed-use buildings?',
          'answer':
              'These are valued separately using commercial valuation methods.'
        }
      ],
    },
  ];
  PageController sliderPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;
  String? selectedPropertyType;
  bool _isLoading = true; // Add this state variable
    final ConstantsController _constantsController = Get.put(ConstantsController());

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

    if (imageList.length >= 2) {
      _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
        if (_currentPage < imageList.length - 1) {
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

  // List<Map<String, dynamic>> get filteredServices {
  //   final typeMapping = {
  //     "Land": "land",
  //     "Houses": "house",
  //     "Villa": "villa",
  //     "Residential Apartments": "apartment",
  //   };

  //   String? filterType;
  //   if (selectedPropertyType != null && selectedPropertyType != "All") {
  //     filterType = typeMapping[selectedPropertyType!];
  //   }

  //   return services.where((service) {
  //     final serviceType = service['type'];
  //     final serviceCity = service['city']?.toLowerCase();

  //     final matchesType = filterType == null || serviceType == filterType;
  //     final matchesCity =
  //         selectedCityKey == null || serviceCity == selectedCityKey;

  //     return matchesType && matchesCity;
  //   }).toList();
  // }

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
              fadeInConfiguration: FadeInConfiguration(duration: Duration(seconds: 2)),
              onSwipeRefresh: () async {},
              children: [
                CustomSliderWithLocation(
                  imageUrls: imageList,
                  currentLocation: selectedCityName ?? 'Select Location',
                  onLocationTap: () {
                    _navigateToCitySelection();
                  },
                ),
                40.height,
                Row(
                  children: [
                    Text("Property Type",
                        style: boldTextStyle(
                          size: 14,
                          color: Theme.of(context).iconTheme?.color,
                        )).paddingSymmetric(horizontal: 16)
                  ],
                ),
                PropertyTypesWidget(
                  types: types,
                  selectedType: selectedPropertyType,
                  onTypeSelected: handlePropertyTypeSelected,
                ),
                20.height,
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

