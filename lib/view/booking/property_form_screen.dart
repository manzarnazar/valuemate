import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  List<PlatformFile> propertyDocuments = [];
  Map<int, String> documentTextValues =
      {}; // Store text values by document requirement ID
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
        service_type_ar: service.serviceTypeAr,
      );
    }).toList();
  }

  String getDocumentDisplayName(DocumentRequirement doc) {
    final currentLang = Get.locale?.languageCode ?? 'en';
    return (currentLang == 'ar' && doc.documentNameAr != null && doc.documentNameAr!.isNotEmpty)
        ? doc.documentNameAr!
        : doc.documentName;
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
    // Check if there are required documents
    final requiredDocs = getRequiredDocuments();
    final hasDocuments = requiredDocs.isNotEmpty;

    if (widget.preSelected) {
      // If preselected and no documents, skip document step
      return (showDocumentStep && hasDocuments) ? 4 : 3;
    } else {
      // If not preselected and no documents, skip document step
      return (showDocumentStep && hasDocuments) ? 5 : 4;
    }
  }

  List<DocumentRequirement> getRequiredDocuments() {
    if (selectedPropertyId == null || selectedServiceType == null) {
      return [];
    }

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
    final msg = _constantsController.settings.firstWhereOrNull(
      (setting) => setting.key == "company_selection_msg",
    );
    return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("confirm_company".tr,
                  style: boldTextStyle(color: Colors.orange)),
              content: Text(msg?.value ??
                  'Are you sure you want to proceed with this company?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("change_company".tr,
                        style: boldTextStyle(color: Colors.red))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("proceed_company".tr,
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
          "Enter ${getDocumentDisplayName(requirement)}",
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
                  documentTextValues[requirement.id] =
                      textController.text.trim();
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('please_enter_value'
                          .trParams({"docName": getDocumentDisplayName(requirement)}))),
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
        SnackBar(content: Text('please_select_property_type'.tr)),
      );
      return;
    }

    // Step 2: Validate location and area
    if (currentStep == 2) {
      if (selectedCityName.isEmpty || area.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('enter_location_area'.tr)),
        );
        return;
      }

      if (selectedServiceType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a service type')),
        );
        return;
      }
    }

    bool isRequestStep = (widget.preSelected && currentStep == 2) ||
        (!widget.preSelected && currentStep == 3);

    // Step 3 (only when preSelected is false): Select Company
    if (isRequestStep) {
      if (selectedCompany == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('please_select_company'.tr)),
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
        requestTypeId: selectedRequestType?.id ?? 1,
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

      // If there are no required documents, skip this step
      if (requiredDocs.isEmpty) {
        // Go to next step
        if (!_requestController.isLoading.value && currentStep < totalSteps) {
          setState(() {
            currentStep++;
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
        return;
      }

      final documentRequirementIds = getDocumentRequirementIds();

      // Validate that all documents are provided (either file or text)
      for (var doc in requiredDocs) {
        if (doc.isFile != 0) {
          // Check if file is uploaded
          final docIndex = requiredDocs.indexOf(doc);
          if (docIndex >= propertyDocuments.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('please_upload_doc'
                      .trParams({"docName": getDocumentDisplayName(doc)}))),
            );
            return;
          }
        } else {
          // Check if text value is provided
          if (!documentTextValues.containsKey(doc.id) ||
              documentTextValues[doc.id]!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('please_enter_doc'
                      .trParams({"docName": getDocumentDisplayName(doc)}))),
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
          if (docIndex < propertyDocuments.length &&
              propertyDocuments[docIndex].path != null) {
            docFiles.add(File(propertyDocuments[docIndex].path!));
            textValues.add(''); // Empty string for file uploads
          } else {
            docFiles.add(File('')); // Empty file if no document selected
            textValues.add('');
          }
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final PlatformFile file = result.files.first;
      setState(() {
        final requiredDocs = getRequiredDocuments();
        final index = requiredDocs.indexWhere((r) => r.id == requirement.id);

        if (index != -1) {
          if (index < propertyDocuments.length) {
            propertyDocuments[index] = file;
          } else {
            propertyDocuments.add(file);
          }
        }
      });
    }
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
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
      final requiredDocs = getRequiredDocuments();
      final hasDocuments = requiredDocs.isNotEmpty;

      if (currentStep == 1) {
        return "choose_property_type".tr;
      } else if (currentStep == 2) {
        return "location_area".tr;
      } else if (currentStep == 3) {
        if (widget.preSelected) {
          return (showDocumentStep && hasDocuments)
              ? "upload_documents".tr
              : "review_summary".tr;
        } else {
          return "select_company".tr;
        }
      } else if (currentStep == 4) {
        if (widget.preSelected) {
          return "review_summary".tr;
        } else {
          return (showDocumentStep && hasDocuments)
              ? "upload_documents".tr
              : "review_summary".tr;
        }
      } else if (currentStep == 5) {
        return "review_summary".tr;
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
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                "$currentStep of $totalSteps",
                style: secondaryTextStyle(
                  size: 10,
                  color: Theme.of(context).iconTheme.color,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: boldTextStyle(
                size: 16,
                color: Theme.of(context).iconTheme.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // 👈 hides long text with "..."
            ),
          ),
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
      return const Center(child: CircularProgressIndicator());
    }

    // Get current language
    final currentLang = Get.locale?.languageCode ?? 'en';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "property_type_val".tr,
            style: primaryTextStyle(
              size: 16,
              weight: FontWeight.w600,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(height: 16),

          // Loop through property types
          ...propertyTypes.map((propertyType) {
            final (icon, color) =
                PropertyTypeUtils.getIconAndColor(propertyType.name);

            // Use Arabic name if selected language is Arabic
            final displayName = currentLang == 'ar'
                ? propertyType.name_ar
                : propertyType.name;

            return buildPropertyOption(
              displayName,
              propertyType.id,
              icon,
              color,
            );
          }).toList(),

          const SizedBox(height: 10),
        ],
      ),
    );
  });
}


  Widget buildStepTwo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("enter_location_area".tr,
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
                  Icon(Icons.location_on,
                      color: Theme.of(context).primaryColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedCityName.isEmpty
                          ? 'tap_to_select_location'.tr
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
                  textStyle:
                      TextStyle(color: Theme.of(context).iconTheme.color),
                  textFieldType: TextFieldType.NUMBER,
                  decoration: inputDecoration(context, labelText: 'area_label'.tr),
                  onChanged: (val) => area = val,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: selectedUnit,
                  dropdownColor: context.cardColor,
                  decoration: inputDecoration(context, labelText: 'unit'.tr),
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
            decoration: inputDecoration(context, labelText: 'service_type_label'.tr),
            items:
                getServicesForPropertyType(selectedPropertyId).map((service) {
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
                "express_request".tr,
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
      ),
    );
  }

  Widget buildStepThree() {
    if (widget.preSelected) {
      final requiredDocs = getRequiredDocuments();
      final hasDocuments = requiredDocs.isNotEmpty;

      if (showDocumentStep && hasDocuments) {
        return buildStepFour();
      } else {
        return buildStepFive();
      }
    }
    return companySelection();
  }

  Widget buildStepFour() {
    final requiredDocs = getRequiredDocuments();

    // If no documents required, show a message
    if (requiredDocs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              "No documents required",
              style: boldTextStyle(
                  size: 18, color: Theme.of(context).iconTheme.color),
            ),
            SizedBox(height: 8),
            Text(
              "You can proceed to the next step",
              style: secondaryTextStyle(),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("upload_required_documents".tr,
              style: primaryTextStyle(
                  size: 18,
                  weight: FontWeight.w600,
                  color: Theme.of(context).iconTheme.color)),
          SizedBox(height: 16),
          ...requiredDocs
              .map((doc) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getDocumentDisplayName(doc),
                          style: primaryTextStyle(
                              color: Theme.of(context).iconTheme.color)),
                      SizedBox(height: 8),

                      // Show different UI based on isFile value
                      if (doc.isFile != 0) ...[
                        // File upload UI
                        if (propertyDocuments.length >
                            requiredDocs.indexOf(doc))
                          Stack(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: radius(),
                                  border:
                                      Border.all(color: context.dividerColor),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getFileIcon(propertyDocuments[
                                              requiredDocs.indexOf(doc)]
                                          .extension),
                                      size: 40,
                                      color: context.primaryColor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      propertyDocuments[
                                              requiredDocs.indexOf(doc)]
                                          .name,
                                      style: secondaryTextStyle(size: 10),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
                          label: Text("Upload ${getDocumentDisplayName(doc)}",
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
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
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
                                  ? 'Edit ${getDocumentDisplayName(doc)}'
                                  : 'Enter ${getDocumentDisplayName(doc)}',
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
                            selectedCompany!.id, double.tryParse(area) ?? 0.0)
                        : "N/A"),
              ],
            ),
            if (showDocumentStep) const SizedBox(height: 24),
            if (showDocumentStep)
              _buildInfoCard(
                children: [
                  _buildInfoRow("Documents:",
                      "${propertyDocuments.length + documentTextValues.length}"),
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

        if (companyMatch && propertyMatch && areaMatch) {
          setState(() {
            selectedServicePricing = pricing;
          });
        }

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
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(RouteName.loginView);
                      },
                      child: Text("login".tr),
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

    final requiredDocs = getRequiredDocuments();
    final hasDocuments = requiredDocs.isNotEmpty;

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
                    if (widget.preSelected) ...[
                      buildStepFive(),
                    ] else ...[
                      if (showDocumentStep && hasDocuments) buildStepFour(),
                      buildStepFive(),
                    ],
                  ],
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
                        child: Text("back".tr,
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
                                isLastStep ? "pay_now".tr : "next".tr,
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
