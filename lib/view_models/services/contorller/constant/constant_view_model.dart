import 'package:get/get.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';
import 'package:valuemate/repository/constant_repository/constant_repository.dart';

class ConstantsController extends GetxController {
  final ConstantRepository _repository = ConstantRepository();

  final isLoading = false.obs;
  final constants = Rxn<Constants>();
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConstants();
  }

  Future<void> fetchConstants() async {
    isLoading(true);
    error('');

    try {
      final result = await _repository.fetchConstants();
      constants(result);
    } catch (e) {
      error(e.toString());
      Get.snackbar('Error', 'Failed to load constants: $e');
    } finally {
      isLoading(false);
    }
  }

  // Helper getters
  List<PaymentMethod> get paymentMethods => constants.value?.data.paymentMethods ?? [];
  List<ServiceType> get serviceTypes => constants.value?.data.serviceTypes ?? [];
  List<Company> get companies => constants.value?.data.companies ?? [];
  List<Location> get locations => constants.value?.data.locations ?? [];
  List<PropertyType> get propertyTypes => constants.value?.data.propertyTypes ?? [];
  List<RequestType> get requestTypes => constants.value?.data.requestTypes ?? [];
  List<ServicePricing> get servicePricings => constants.value?.data.servicePricings ?? [];
  List<DocumentRequirement> get documentRequirements => constants.value?.data.documentRequirements ?? [];
  List<Status> get statuses => constants.value?.data.statuses ?? [];
  List<Setting> get settings => constants.value?.data.settings ?? [];
  List<PropertyServiceType> get propertyServiceTypes => constants.value?.data.propertyServiceTypes ?? []; 
  String? getSettingValue(String key) {
    return settings.firstWhereOrNull((setting) => setting.key == key)?.value;
  }
}

// Extension for firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}