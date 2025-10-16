import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';
import 'package:valuemate/models/valuation_request_model/valuation_request_model.dart';
import 'package:valuemate/res/routes/routes_name.dart';
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
      Get.find<ConstantsController>();
  final DocumentUploadController _documentController =
      Get.put(DocumentUploadController());
  final ValuationViewModel _requestController = Get.put(ValuationViewModel());

  List<XFile> propertyImages = [];
  List<XFile> propertyDocuments = [];
  Map<int, String> documentTextValues = {}; // Store text values by document requirement ID
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

  bool _isTokenLoaded = false;

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

    final propertyService =
        _constantsController.propertyServiceTypes.firstWhereOrNull(
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

      if (mounted) {
        setState(() {
          token = tok;
          _isTokenLoaded = true;
        });
      }
    } catch (e) {
      print("Error loading token: $e");
      if (mounted) {
        setState(() {
          _isTokenLoaded = true;
        });
      }
    }
  }

  bool get showDocumentStep {
    try {
      final documentStepSetting = _constantsController.settings.firstWhere(
        (setting) => setting.key == "dcoument_step",
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
    final msg = _constantsController.settings.firstWhere(
      (setting) => setting.key == "company_selection_msg",
    );
    return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Confirm Company Selection",
                  style: boldTextStyle(color: Colors.orange)),
              content: Text(msg.value),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("CHANGE COMPANY",
                        style: boldTextStyle(color: Colors.red))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("PROCEED",
                        style: boldTextStyle(color: Colors.green)))
              ],
            ));
  }

  // Show dialog to get text input from user
  Future<void> _showTextInputDialog(DocumentRequirement requirement) async {
    final TextEditingController textController = TextEditingController(
      text: documentTextValues[requirement.id] ?? '',
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Enter ${requirement.documentName}",
          style: boldTextStyle(color: Theme.of(context).iconTheme.color),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: "Enter value here",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: boldTextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                setState(() {
                  documentTextValues[requirement.id] = textController.text.trim();
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a value')),
                );
              }
            },
            child: Text("SAVE", style: boldTextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void goToNextStep() async {
    // Step 1: Validate property type
    if (currentStep == 1 && selectedProperty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a property type')),
      );
      return;
    }

    // Step 2: Validate location and area
    if (currentStep == 2 && (selectedCityName.isEmpty || area.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all location details')),
      );
      return;
    }

    bool isRequestStep = (widget.preSelected && currentStep == 2) ||
        (!widget.preSelected && currentStep == 3);

    // Step 3 (only when preSelected is false): Select Company
    if (isRequestStep) {
      if (selectedCompany == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a company')),
        );
        return;
      }

      final shouldProceed = await _showCompanyConfirmationDialog();
      if (shouldProceed == null) return;
      if (!shouldProceed) {
        _showCompanyBottomSheet();
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

      await _requestController.createValuationRequest(requestData, token!);

      if (_requestController.isLoading.value) return;
      if (_requestController.errorMessage.value.isNotEmpty) {
        return;
      }
    }

    bool isDocumentStep = (widget.preSelected && currentStep == 3) ||
        (!widget.preSelected && currentStep == 4);

    if (isDocumentStep && showDocumentStep) {
      final requiredDocs = getRequiredDocuments();
      final documentRequirementIds = getDocumentRequirementIds();

      // Validate that all documents are provided (either file or text)
      for (var doc in requiredDocs) {
        if (doc.isFile != 0) {
          // Check if file is uploaded
          final docIndex = requiredDocs.indexOf(doc);
          if (docIndex >= propertyDocuments.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please upload ${doc.documentName}')),
            );
            return;
          }
        } else {
          // Check if text value is provided
          if (!documentTextValues.containsKey(doc.id) || 
              documentTextValues[doc.id]!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter ${doc.documentName}')),
            );
            return;
          }
        }
      }

      // Prepare document files and text values
      List<File> docFiles = [];
      List<String> textValues = [];
      
      for (var doc in requiredDocs) {
        if (doc.isFile != 0) {
          final docIndex = requiredDocs.indexOf(doc);
          docFiles.add(File(propertyDocuments[docIndex].path));
          textValues.add(''); // Empty string for file uploads
        } else {
          docFiles.add(File('')); // Empty file for text inputs
          textValues.add(documentTextValues[doc.id] ?? '');
        }
      }

      await _documentController.uploadDocuments(
        valuationRequestId: _requestController.request_id.value,
        documentRequirementIds: documentRequirementIds,
        documentFiles: docFiles,
        documentTextValues: textValues, // Pass the text values array
        token: token!,
      );

      if (_documentController.isLoading.value) return;
      if (_documentController.errorMessage.value.isNotEmpty) {
        return;
      }
    }

    // Go to next step if all validations passed
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

  Future<void> pickDocumentForRequirement(
      DocumentRequirement requirement) async {
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
                  style: boldTextStyle(
                      size: 20, color: Theme.of(context).iconTheme.color),
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
                                    content:
                                        Text('Please select a payment method')),
                              );
                              return;
                            }

                            if (selectedCompany == null ||
                                user == null ||
                                token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Some required data is missing')),
                              );
                              return;
                            }

                            if (selectedPaymentMethodId == 1) {
                              try {
                                _requestController.isLoading.value = true;
                                final valuationRequestId =
                                    _requestController.request_id.value;

                                final paymentResponse =
                                    await _requestController.initiatePayment(
                                  valuationRequestId: valuationRequestId,
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
                                                'Payment initiation failed')),
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
                              Get.snackbar("COMING SOON", "Work in Progress");
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
    String getStepTitle() {
      if (currentStep == 1) {
        return "Choose Property Type";
      } else if (currentStep == 2) {
        return "Location and Area";
      } else if (currentStep == 3) {
        return widget.preSelected ? "Upload Documents" : "Select Company";
      } else if (currentStep == 4) {
        return widget.preSelected ? "Review Summary" : "Upload Documents";
      } else if (currentStep == 5) {
        return "Review Summary";
      } else {
        return "";
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getStepTitle(),
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
            Text(
              "$currentStep of $totalSteps",
              style: secondaryTextStyle(
                size: 10,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
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
          selectedServiceType = null;
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
      final propertyTypes = _constantsController.propertyTypes;
      debugPrint("buildStepOne() -> ${propertyTypes.length} property types");

      if (propertyTypes.isEmpty) {
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
            ...propertyTypes.map((propertyType) {
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
              value: selectedRequestType?.id == 2,
              onChanged: (value) {
                setState(() {
                  selectedRequestType = _constantsController.requestTypes
                      .firstWhere((type) => type.id == (value ? 2 : 1));
                });
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
          ...requiredDocs
              .map((doc) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.documentName,
                          style: primaryTextStyle(
                              color: Theme.of(context).iconTheme.color)),
                      SizedBox(height: 8),
                      
                      // Show different UI based on isFile value
                      if (doc.isFile != 0) ...[
                        // File upload UI
                        if (propertyDocuments.length > requiredDocs.indexOf(doc))
                          Stack(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(File(propertyDocuments[
                                            requiredDocs.indexOf(doc)]
                                        .path)),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: radius(),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: IconButton(
                                  icon: Icon(Icons.close,
                                      size: 18, color: Colors.red),
                                  onPressed: () {
                                    setState(() => propertyDocuments
                                        .removeAt(requiredDocs.indexOf(doc)));
                                  },
                                ),
                              )
                            ],
                          ),
                        ElevatedButton.icon(
                          onPressed: () {
                            pickDocumentForRequirement(doc);
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              backgroundColor: context.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius(defaultRadius))),
                          icon: Icon(Icons.upload_file, color: Colors.white),
                          label: Text("Upload ${doc.documentName}",
                              style:
                                  boldTextStyle(size: 16, color: Colors.white)),
                        ),
                      ] else ...[
                        // Text input UI
                        if (documentTextValues.containsKey(doc.id) && 
                            documentTextValues[doc.id]!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    documentTextValues[doc.id]!,
                                    style: primaryTextStyle(
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showTextInputDialog(doc);
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              backgroundColor: context.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius(defaultRadius))),
                          icon: Icon(Icons.edit, color: Colors.white),
                          label: Text(
                              documentTextValues.containsKey(doc.id) 
                                  ? "Edit ${doc.documentName}"
                                  : "Enter ${doc.documentName}",
                              style:
                                  boldTextStyle(size: 16, color: Colors.white)),
                        ),
                      ],
                      SizedBox(height: 16),
                    ],
                  ))
              .toList(),
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
            if (showDocumentStep) const SizedBox(height: 24),
            if (showDocumentStep)
              _buildInfoCard(
                children: [
                  _buildInfoRow("Documents:", "${propertyDocuments.length + documentTextValues.length}"),
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
                      "${_requestController.price.value} OMR",
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

  return matchingPricings.first.price.replaceAll(".000", "");
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
    if (!_isTokenLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (token == null || token!.isEmpty) {
      return Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome Back!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            16.height,
            Text("Login to your account to continue",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            16.height,
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(RouteName.loginView);
                      },
                      child: Text("Login"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
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
      );
    }
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
                    if (widget.preSelected)
                      buildStepFive()
                    else if (showDocumentStep)
                      buildStepFour(),
                    if (!widget.preSelected) buildStepFive(),
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
                  Obx(() {
                    final isRequestLoading = _requestController.isLoading.value;
                    final isDocLoading = _documentController.isLoading.value;
                    final isLoading = isRequestLoading || isDocLoading;
                    final isLastStep = currentStep == totalSteps;

                    return Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : isLastStep
                                ? _showPaymentMethodBottomSheet
                                : goToNextStep,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              isLoading ? Colors.grey : context.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: radius(defaultRadius),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                isLastStep ? "Pay Now" : "NEXT",
                                style: boldTextStyle(
                                    size: 16, color: Colors.white),
                              ),
                      ),
                    );
                  }),
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