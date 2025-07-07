import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/auth_model/auth_response.model.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';
import 'package:valuemate/models/valuation_request_model/valuation_request_model.dart';
import 'package:valuemate/res/colors/app_color.dart';
import 'package:valuemate/utlis/themeutlis.dart';
import 'package:valuemate/view/dashboard/components/citySelection.dart';
import 'package:valuemate/view/dashboard/components/service_component.dart';
import 'package:valuemate/view/paymentScreen/PaymentWebview.dart';
import 'package:valuemate/view_models/services/contorller/auth/user_prefrence_view_model.dart';
import 'package:valuemate/view_models/services/contorller/constant/constant_view_model.dart';
import 'package:valuemate/view_models/services/contorller/documents_upload/document_upload_view_model.dart';
import 'package:valuemate/view_models/valuation_request_model/valuation_request_view_model.dart';

class PropertyForm extends StatefulWidget {
  final bool preSelected;
  final Company? selectedCompany;

  const PropertyForm(
      {super.key, this.preSelected = false, this.selectedCompany});
  @override
  _PropertyFormState createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  PageController _pageController = PageController();
  int currentStep = 1;
  String selectedProperty = "";
  int? selectedPropertyId;
  final ConstantsController _constantsController =
      Get.put(ConstantsController());
  final DocumentUploadController _documentController =
      Get.put(DocumentUploadController());
  final ValuationViewModel _requestController =
      Get.put(ValuationViewModel());

  List<XFile> propertyImages = [];
  List<XFile> propertyDocuments = [];
  final ImagePicker _picker = ImagePicker();

  // Step 2 inputs
  String selectedCityName = '';
  int? selectedCityKey;
  String area = '';
  String selectedUnit = 'sq ft';
  ServiceType? selectedServiceType;
  ServicePricing? selectedServicePricing;
  RequestType? selectedRequestType;
  List<String> areaUnits = ['sq ft', 'sq m', 'acre', 'hectare'];




  Company? selectedCompany;
  String? token;

  @override
  void initState() {
    super.initState();

    final company = widget.selectedCompany;
    if (company != null) {
      selectedCompany = company;
    }

    _requestController.resetIdValue(); 
    _loadToken();
  }

List<ServiceType> getServicesForPropertyType(int? propertyTypeId) {
  if (propertyTypeId == null) return [];

  final propertyService = _constantsController.propertyServiceTypes.firstWhereOrNull(
    (pst) => pst.propertyTypeId == propertyTypeId,
  );

  if (propertyService == null) return [];

  return propertyService.services.map((service) {
    return ServiceType(
      serviceTypeId: service.serviceTypeId,
      serviceType: service.serviceType,
    );
  }).toList();
}

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tok = prefs.getString('token');
      // print("Token from SharedPreferences: $tok");

      if (mounted) { 
        setState(() {
          token = tok;
        });
      }
    } catch (e) {
      print("Error loading token: $e");
    }
  }

  bool get showDocumentStep {
    try {
      final documentStepSetting = _constantsController.settings.firstWhere(
        (setting) =>
            setting.key == "dcoument_step",
      );
      return documentStepSetting.value == "1";
    } catch (e) {
      return false;
    }
  }

  int get totalSteps {
    return widget.preSelected
        ? (showDocumentStep ? 4 : 3)
        : (showDocumentStep ? 5 : 4);
  }

  List<DocumentRequirement> getRequiredDocuments() {
    return _constantsController.documentRequirements.where((req) {
      return req.propertyTypeId == selectedPropertyId && 
             req.serviceTypeId == selectedServiceType?.serviceTypeId;
    }).toList();
  }


  List<int> getDocumentRequirementIds() {
  if (selectedPropertyId == null || selectedServiceType == null) {
    return [];
  }

  return _constantsController.documentRequirements
      .where((req) => 
          req.propertyTypeId == selectedPropertyId && 
          req.serviceTypeId == selectedServiceType!.serviceTypeId)
      .map((req) => req.id)
      .toList();
}

  Future<bool?> _showCompanyConfirmationDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Confirm Company Selection",style: boldTextStyle(color: Colors.orange)),
      content: Text("You have selected ${selectedCompany?.name}. Do you want to proceed with this company or change it?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Change company
          child: Text("CHANGE COMPANY", style: boldTextStyle(color: Colors.red))),
        TextButton(
          onPressed: () => Navigator.pop(context, true), // Proceed
          child: Text("PROCEED", style: boldTextStyle(color: Colors.green)))],
    ));
}

  void goToNextStep() async {
  if (currentStep == 1 && selectedProperty.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a property type')),
    );
    return;
  }
  if (currentStep == 2 && (selectedCityName.isEmpty || area.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all location details')),
    );
    return;
  }
  
  // Handle company selection step
  if (currentStep == 3 && !widget.preSelected) {
    if (selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a company')),
      );
      return;
    }
    
    // Show confirmation dialog
    final shouldProceed = await _showCompanyConfirmationDialog();
    if (shouldProceed == null) {
      return; // Dialog was dismissed
    }
    if (!shouldProceed) {
      _showCompanyBottomSheet(); // Show company selection again
      return;
    }


    final user = await UserPreference().getUser();
    final requestData = ValuationRequest(
      valuation_request_id: _requestController.request_id.value,
      companyId: selectedCompany!.id,
      userId: user!.id,
      propertyTypeId: selectedPropertyId,
      serviceTypeId: selectedServiceType?.serviceTypeId,
      requestTypeId: 1,
      locationId: selectedCityKey?.toInt() ?? 0,
      area: int.tryParse(area) ?? 0,
      reference: '123abc',
    );
    
    // Print all values before API call
// print('valuation_request_id: ${_requestController.request_id.value}');
// print('companyId: ${selectedCompany!.id}');
// print('userId: ${user!.id}');
// print('propertyTypeId: $selectedPropertyId');
// print('serviceTypeId: ${selectedServiceType?.serviceTypeId}');
// print('requestTypeId: 1');
// print('locationId: ${selectedCityKey?.toInt() ?? 0}');
// print('areaFrom: ${selectedServicePricing}');
// print('areaTo: ${selectedServicePricing}');
// print('area: ${int.tryParse(area) ?? 0}');
// print('reference: 123abc');


    await _requestController.createValuationRequest(requestData, token!);

    print(_requestController.price.value);

 
  
    if (_requestController.isLoading.value) {
      return;
    }
    
    // Check if request was successful before proceeding
    // if (_requestController.request_id.value == 0) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Valueation Request Created.')),
    //   );
    //   return;
    // }
  }

  // Rest of your existing code...
  if(showDocumentStep && currentStep == 4) {
  final requiredDocs = getRequiredDocuments();
  final documentRequirementIds = getDocumentRequirementIds();
  
  if (propertyDocuments.length != requiredDocs.length) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please upload all required documents')),
    );
    return;
  }
  
  List<File> docFiles = propertyDocuments.map((xfile) => File(xfile.path)).toList();
  
  await _documentController.uploadDocuments(
    valuationRequestId: _requestController.request_id.value,
    documentRequirementIds: documentRequirementIds,
    documentFiles: docFiles,
    token: token!,
  );
}


  if (!_requestController.isLoading.value && currentStep < totalSteps) {
    setState(() {
      currentStep++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}
  void goToPreviousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
        _pageController.previousPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        propertyImages.addAll(images);
      });
    }
  }

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

 Future<void> pickDocumentForRequirement(DocumentRequirement requirement) async {
  final XFile? doc = await _picker.pickImage(source: ImageSource.gallery);
  if (doc != null) {
    setState(() {
      final requiredDocs = getRequiredDocuments();
      final index = requiredDocs.indexWhere((r) => r.id == requirement.id);
      
      if (index != -1) {
        if (index < propertyDocuments.length) {
          propertyDocuments[index] = doc;
        } else {
          propertyDocuments.add(doc);
        }
      }
    });
  }
}
  void _showCompanyBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Company",
              style: boldTextStyle(
                  size: 20, color: Theme.of(context).iconTheme.color),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 14,
                  children: _constantsController.companies.map((service) {
                    bool isSelected = selectedCompany == service;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCompany = service;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 42) / 2,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: radius(14),
                        ),
                        child: ServiceComponent(
                          serviceData: service,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
                "Select Payment Method",
                style: boldTextStyle(size: 20, color: Theme.of(context).iconTheme.color),
              ),
              SizedBox(height: 20),
              Obx(() {
                if (_constantsController.paymentMethods.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No payment methods available",
                      style: secondaryTextStyle(),
                    ),
                  );
                }

                return SizedBox(
                  height: 200, // Use fixed height if inside a bottom sheet
                  child: ListView(
                    shrinkWrap: true,
                    children: _constantsController.paymentMethods.map((method) {
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
                              SnackBar(content: Text('Please select a payment method')),
                            );
                            return;
                          }

                          if (selectedCompany == null || user == null || token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Some required data is missing')),
                            );
                            return;
                          }

                          try {
                            _requestController.isLoading.value = true;
                            final valuationRequestId = _requestController.request_id.value;

                            final paymentResponse = await _requestController.initiatePayment(
                              valuationRequestId: valuationRequestId,
                              paymentMethodId: selectedPaymentMethodId!,
                              token: token!,
                            );

                            print(paymentResponse);

                            if (paymentResponse['status'] == true &&
                                paymentResponse['data']?['url'] != null) {
                              final checkoutUrl = paymentResponse['data']['url'];
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewPage(url: checkoutUrl),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(paymentResponse['message'] ?? 'Payment initiation failed')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          } finally {
                            _requestController.isLoading.value = false;
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
                          "Proceed to Payment",
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



  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          currentStep == 1
              ? "Choose Property Type"
              : currentStep == 2
                  ? "Location and Area"
                  : currentStep == 3
                      ? widget.preSelected
                          ? "Review Summary"
                          : "Select Company"
                      : currentStep == 4
                          ? showDocumentStep
                            ? "Upload Documents"
                            : "Review Summary"
                          : "Review Summary",
          style:
              boldTextStyle(size: 22, color: Theme.of(context).iconTheme.color),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                value: currentStep / totalSteps,
                strokeWidth: 4,
                backgroundColor: context.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
              ),
            ),
            Text("$currentStep of $totalSteps",
                style: secondaryTextStyle(
                    size: 10, color: Theme.of(context).iconTheme.color)),
          ],
        )
      ],
    );
  }

  Widget buildPropertyOption(String title, int id, IconData icon, Color color) {
    bool isSelected = selectedProperty == title;
    return GestureDetector(
    onTap: () {
  setState(() {
    selectedProperty = title;
    selectedPropertyId = id;
    selectedServiceType = null; // Reset based on new property
  });
},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : context.cardColor,
          border: Border.all(
            color: isSelected ? color : context.dividerColor,
            width: 1.5,
          ),
          borderRadius: radius(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text(title,
                style: boldTextStyle(
                    size: 16, color: Theme.of(context).iconTheme.color)),
          ],
        ),
      ),
    );
  }

  Widget buildStepOne() {
    return Obx(() {
      if (_constantsController.propertyTypes.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What type of property valuation are you looking for?",
              style: primaryTextStyle(
                size: 16,
                weight: FontWeight.w600,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            SizedBox(height: 16),
            ..._constantsController.propertyTypes.map((propertyType) {
              final (icon, color) =
                  PropertyTypeUtils.getIconAndColor(propertyType.name);
              return buildPropertyOption(
                propertyType.name,
                propertyType.id,
                icon,
                color,
              );
            }).toList(),
            SizedBox(height: 10),
          ],
        ),
      );
    });
  }

  Widget buildStepTwo() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Enter the Location and Area of the Property",
          style: primaryTextStyle(
              size: 18,
              weight: FontWeight.w600,
              color: Theme.of(context).iconTheme.color)),
      SizedBox(height: 16),
      GestureDetector(
        onTap: () {
          _navigateToCitySelection();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).primaryColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedCityName.isEmpty
                      ? 'Tap to select location'
                      : selectedCityName,
                  style: TextStyle(
                    color: selectedCityName.isEmpty
                        ? Colors.grey
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
      SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            flex: 3,
            child: AppTextField(
              initialValue: area,
              textStyle: TextStyle(color: Theme.of(context).iconTheme.color),
              textFieldType: TextFieldType.NUMBER,
              decoration: inputDecoration(context, labelText: 'Area'),
              onChanged: (val) => area = val,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedUnit,
              dropdownColor: context.cardColor,
              decoration: inputDecoration(context, labelText: 'Unit'),
              items: areaUnits.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit,
                      style: primaryTextStyle(
                          color: Theme.of(context).iconTheme.color)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => selectedUnit = newValue!);
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      DropdownButtonFormField<ServiceType>(
        value: selectedServiceType,
        dropdownColor: context.cardColor,
        decoration: inputDecoration(context, labelText: 'Service Type'),
        items: getServicesForPropertyType(selectedPropertyId).map((service) {
          return DropdownMenuItem<ServiceType>(
            value: service,
            child: Text(service.serviceType,
                style: primaryTextStyle(
                    color: Theme.of(context).iconTheme.color)),
          );
        }).toList(),
        onChanged: (ServiceType? newValue) {
          setState(() => selectedServiceType = newValue!);
        },
      ),
      SizedBox(height: 16),
      // Request Type Switch
      Row(
        children: [
          Text(
            "Express Request (Faster)",
            style: primaryTextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          Spacer(),
          Switch(
            value: selectedRequestType?.id == 2, // True for Express (id:2)
            onChanged: (value) {
              setState(() {
                selectedRequestType = _constantsController.requestTypes
                    .firstWhere((type) => type.id == (value ? 2 : 1));
              });
              // Add any additional logic when request type changes
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
      if (selectedRequestType != null)
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            selectedRequestType!.description,
            style: secondaryTextStyle(
              color: Colors.grey,
              size: 12,
            ),
          ),
        ),
    ],
  );
}

  Widget buildStepThree() {
    if (widget.preSelected) {
      return buildStepFour();
    }
    return companySelection();
  }

  Widget buildStepFour() {
    final requiredDocs = getRequiredDocuments();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Upload Required Documents",
              style: primaryTextStyle(
                  size: 18,
                  weight: FontWeight.w600,
                  color: Theme.of(context).iconTheme.color)),
          SizedBox(height: 16),
          
          ...requiredDocs.map((doc) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.documentName,
                  style: primaryTextStyle(
                      color: Theme.of(context).iconTheme.color)),
              SizedBox(height: 8),
              
              if (propertyDocuments.length > requiredDocs.indexOf(doc))
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(propertyDocuments[requiredDocs.indexOf(doc)].path)),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: radius(),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () {
                          setState(() => propertyDocuments.removeAt(requiredDocs.indexOf(doc)));
                        },
                      ),
                    )
                  ],
                ),
            
              ElevatedButton.icon(
                onPressed: () => pickDocumentForRequirement(doc),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: radius(defaultRadius))),
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text("Upload ${doc.documentName}",
                    style: boldTextStyle(size: 16, color: Colors.white)),
              ),
              SizedBox(height: 16),
            ],
          )).toList(),
          
          SizedBox(height: 32),
          // Text("Upload Property Images",
          //     style: primaryTextStyle(
          //         size: 18,
          //         weight: FontWeight.w600,
          //         color: Theme.of(context).iconTheme.color)),
          // SizedBox(height: 16),
          // Wrap(
          //   spacing: 12,
          //   runSpacing: 12,
          //   children: propertyImages.map((file) {
          //     return Stack(
          //       children: [
          //         Container(
          //           height: 100,
          //           width: 100,
          //           decoration: BoxDecoration(
          //             image: DecorationImage(
          //               image: FileImage(File(file.path)),
          //               fit: BoxFit.cover,
          //             ),
          //             borderRadius: radius(),
          //           ),
          //         ),
          //         Positioned(
          //           top: 2,
          //           right: 2,
          //           child: IconButton(
          //             icon: Icon(Icons.close, size: 18, color: Colors.red),
          //             onPressed: () {
          //               setState(() => propertyImages.remove(file));
          //             },
          //           ),
          //         )
          //       ],
          //     );
          //   }).toList(),
          // ),
          // SizedBox(height: 12),
          // ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          //       backgroundColor: context.primaryColor,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: radius(defaultRadius))),
          //   onPressed: pickImages,
          //   icon: Icon(Icons.add_a_photo, color: Colors.white),
          //   label: Text("Add Image",
          //       style: boldTextStyle(size: 16, color: Colors.white)),
          // ),
        ],
      ),
    );
  }

  Widget buildStepFive() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            children: [
              _buildInfoRow("Property Type:", selectedProperty),
              const SizedBox(height: 12),
              _buildInfoRow("Location:", selectedCityName),
              const SizedBox(height: 12),
              _buildInfoRow("Area:", "$area $selectedUnit"),
              const SizedBox(height: 12),
              if (selectedServiceType != null)
                _buildInfoRow(
                    "Service Type:", selectedServiceType!.serviceType),
            ],
          ),

          if (selectedCompany != null) ...[
            const SizedBox(height: 15),
            // if (widget.preSelected)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       TextButton(
            //           onPressed: () {
            //             _showCompanyBottomSheet();
            //           },
            //           child: Text(
            //             "Change Company",
            //             style: boldTextStyle(color: context.primaryColor),
            //           ))
            //     ],
            //   ),
            const SizedBox(height: 5),
            _buildInfoCard(
              children: [
                _buildInfoRow(
                    "Company:", selectedCompany?.name ?? "Not selected"),
                const SizedBox(height: 10),
                _buildInfoRow(
                    "Price:",
                    selectedCompany != null && selectedPropertyId != null
                        ? _getPriceForCompany(
                            selectedCompany!.id, area.toDouble())
                        : "N/A"),
              ],
            ),
                if(showDocumentStep)
            const SizedBox(height: 24),
                if(showDocumentStep)
            _buildInfoCard(
              children: [
                _buildInfoRow(
                    "Documents Uploaded:", "${propertyDocuments.length}"),
                const SizedBox(height: 12),
                _buildInfoRow("Images Uploaded:", "${propertyImages.length}"),
              ],
            ),
          ],

          const SizedBox(height: 20),
          if (selectedCompany != null)
            Container(
              child: _buildInfoCard(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Price:",
                      style: primaryTextStyle(
                        size: 18,
                        weight: FontWeight.w600,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Text(
                      selectedCompany != null && selectedPropertyId != null
                          ? _getPriceForCompany(
                              selectedCompany!.id, area.toDouble())
                          : "N/A",
                      style: boldTextStyle(
                        size: 22,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

String _getPriceForCompany(int companyId, double area) {
    if (selectedPropertyId == null) return "N/A";

    try {
      final matchingPricings =
          _constantsController.servicePricings.where((pricing) {
        final companyMatch = pricing.companyId == companyId;
        final propertyMatch = pricing.propertyTypeId == selectedPropertyId;
        final areaMatch = area >= pricing.areaFrom && area <= pricing.areaTo;
        setState(() {
          selectedServicePricing = pricing;
        });

        return companyMatch && propertyMatch && areaMatch;
      }).toList();

      if (matchingPricings.isEmpty) {
        return "N/A";
      }

      return "\$${matchingPricings.first.price.replaceAll(".000", "")}";
    } catch (e) {
      return "N/A";
    }
  }


  Widget companySelection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 14,
            children: _constantsController.companies.map((service) {
              bool isSelected = selectedCompany == service;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCompany = service;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: radius(14),
                  ),
                  child: ServiceComponent(
                    width: MediaQuery.of(context).size.width / 2 - 28,
                    serviceData: service,
                  ),
                ),
              );
            }).toList(),
          ),
          10.height,
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: primaryTextStyle(
              weight: FontWeight.w600,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: primaryTextStyle(color: Theme.of(context).iconTheme.color),
          ),
        ),
      ],
    );
  }

  
  @override
  Widget build(BuildContext context) {
// print(selectedRequestType!.id);
    // getServicesForPropertyType(selectedProperty.toInt());
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              buildHeader(),
              SizedBox(height: 32),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    buildStepOne(),
                    buildStepTwo(),
                    buildStepThree(),
                    if(widget.preSelected) buildStepFive() else if (showDocumentStep) buildStepFour(),
                    // buildStepFive(),
                  ].where((child) => child != null).toList(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  if (currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: goToPreviousStep,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: context.primaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: radius(defaultRadius)),
                        ),
                        child: Text("BACK",
                            style: primaryTextStyle(
                                size: 16,
                                color: Theme.of(context).iconTheme.color)),
                      ),
                    ),
                  if (currentStep > 1) SizedBox(width: 16),
                  Obx(
                    () =>  
                    _requestController.isLoading.value ? CircularProgressIndicator() : Expanded(
  child: ElevatedButton(
    onPressed: _requestController.isLoading.value 
      ? null 
      : (currentStep == totalSteps 
          ? _showPaymentMethodBottomSheet 
          : goToNextStep),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16),
      backgroundColor: _requestController.isLoading.value 
        ? Colors.grey 
        : context.primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: radius(defaultRadius)),
    ),
    child:
       Text(
          currentStep == totalSteps ? "Pay Now" : "NEXT",
          style: boldTextStyle(size: 16, color: Colors.white)),
  ),
),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyTypeUtils {
  static (IconData, Color) getIconAndColor(String propertyName) {
    switch (propertyName.toLowerCase()) {
      case 'house':
        return (Icons.house, Colors.blue);
      case 'apartments':
        return (Icons.apartment, Colors.orange);
      case 'residential land':
        return (Icons.terrain, Colors.green);
      case 'agricultural land':
        return (Icons.agriculture, Colors.brown);
      case 'industrial land':
        return (Icons.factory, Colors.grey);
      case 'commercial land':
        return (Icons.business, Colors.blueGrey);
      case 'commercial shops':
        return (Icons.store, Colors.teal);
      case 'commercial buildings':
        return (Icons.apartment, Colors.blue);
      case 'residential complexes':
        return (Icons.maps_home_work, Colors.indigo);
      case 'commercial complexes':
        return (Icons.location_city, Colors.deepOrange);
      case 'warehouses':
        return (Icons.warehouse, Colors.amber);
      case 'factories':
        return (Icons.factory, Colors.redAccent);
      default:
        return (Icons.home, Colors.blue);
    }
  }
}