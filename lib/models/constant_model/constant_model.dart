
class Constants {
  final bool status;
  final Data data;

  Constants({
    required this.status,
    required this.data,
  });

  factory Constants.fromJson(Map<String, dynamic> json) {
    return Constants(
      status: json['status'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}
class Data {
  final List<PaymentMethod> paymentMethods;
  final List<ServiceType> serviceTypes;
  final List<Company> companies;
  final List<Location> locations;
  final List<PropertyType> propertyTypes;
  final List<PropertyServiceType> propertyServiceTypes;
  final List<RequestType> requestTypes;
  final List<ServicePricing> servicePricings;
  final List<DocumentRequirement> documentRequirements;
  final List<Status> statuses;
  final List<Setting> settings;
  final List<Banner> banners; // ✅ NEW

  Data({
    required this.paymentMethods,
    required this.serviceTypes,
    required this.companies,
    required this.locations,
    required this.propertyTypes,
    required this.propertyServiceTypes,
    required this.requestTypes,
    required this.servicePricings,
    required this.documentRequirements,
    required this.statuses,
    required this.settings,
    required this.banners, // ✅ NEW
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      paymentMethods: (json['payment_methods'] as List<dynamic>?)
              ?.map((e) => PaymentMethod.fromJson(e))
              .toList() ??
          [],
      serviceTypes: (json['service_types'] as List<dynamic>?)
              ?.map((e) => ServiceType.fromJson(e))
              .toList() ??
          [],
      companies: (json['companies'] as List<dynamic>?)
              ?.map((e) => Company.fromJson(e))
              .toList() ??
          [],
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => Location.fromJson(e))
              .toList() ??
          [],
      propertyTypes: (json['property_types'] as List<dynamic>?)
              ?.map((e) => PropertyType.fromJson(e))
              .toList() ??
          [],
      propertyServiceTypes: (json['property_service_types'] as List<dynamic>?)
              ?.map((e) => PropertyServiceType.fromJson(e))
              .toList() ??
          [],
      requestTypes: (json['request_types'] as List<dynamic>?)
              ?.map((e) => RequestType.fromJson(e))
              .toList() ??
          [],
      servicePricings: (json['service_pricings'] as List<dynamic>?)
              ?.map((e) => ServicePricing.fromJson(e))
              .toList() ??
          [],
      documentRequirements: (json['document_requirements'] as List<dynamic>?)
              ?.map((e) => DocumentRequirement.fromJson(e))
              .toList() ??
          [],
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => Status.fromJson(e))
              .toList() ??
          [],
      settings: (json['settings'] as List<dynamic>?)
              ?.map((e) => Setting.fromJson(e))
              .toList() ??
          [],
      banners: (json['banners'] as List<dynamic>?) // ✅ NEW
              ?.map((e) => Banner.fromJson(e))
              .toList() ??
          [],
    );
  }
}



class PaymentMethod {
  final int id;
  final String name;

  PaymentMethod({
    required this.id,
    required this.name,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class PropertyServiceType {
  final String propertyType;
  final int propertyTypeId;
  final List<Service> services;

  PropertyServiceType({
    required this.propertyType,
    required this.propertyTypeId,
    required this.services,
  });

  factory PropertyServiceType.fromJson(Map<String, dynamic> json) {
    return PropertyServiceType(
      propertyType: json['property_type'] ?? '',
      propertyTypeId: json['property_type_id'] ?? 0,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Service {
  final int id;
  final int serviceTypeId;
  final String serviceType;

  Service({
    required this.id,
    required this.serviceTypeId,
    required this.serviceType,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      serviceTypeId: json['service_type_id'] ?? 0,
      serviceType: json['service_type'] ?? '',
    );
  }
}

class ServiceType {
  final int serviceTypeId;
  final String serviceType;

  ServiceType({
    required this.serviceTypeId,
    required this.serviceType,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      serviceTypeId: json['service_type_id'] ?? 0,
      serviceType: json['service_type'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceType &&
          runtimeType == other.runtimeType &&
          serviceTypeId == other.serviceTypeId;

  @override
  int get hashCode => serviceTypeId.hashCode;
}

class Company {
  final int id;
  final String file;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String status;
  final String description;

  Company({
    required this.id,
    required this.file,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.status,
    required this.description,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      file: json['file'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Location {
  final int id;
  final String name;

  Location({
    required this.id,
    required this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class PropertyType {
  final int id;
  final String name;
  final String image_url;
  


  PropertyType({
    required this.id,
    required this.name,
    required this.image_url,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image_url: json['image_url'] ?? '',
    );
  }
}

class Banner {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final String adType;
  final String startDate;
  final String endDate;
  final String createdAtDate;
  final String createdAtTime;

  Banner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.adType,
    required this.startDate,
    required this.endDate,
    required this.createdAtDate,
    required this.createdAtTime,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      link: json['link'] ?? '',
      adType: json['ad_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      createdAtDate: json['created_at_date'] ?? '',
      createdAtTime: json['created_at_time'] ?? '',
    );
  }
}

class RequestType {
  final int id;
  final String name;
  final String description;

  RequestType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RequestType.fromJson(Map<String, dynamic> json) {
    return RequestType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ServicePricing {
  final int id;
  final int? service_type_id; // Note the underscore
  final int propertyTypeId;
  final int companyId;
  final int requestTypeId;
  final int areaFrom;
  final int areaTo;
  final String price;

  ServicePricing({
    required this.id,
    this.service_type_id,
    required this.propertyTypeId,
    required this.companyId,
    required this.requestTypeId,
    required this.areaFrom,
    required this.areaTo,
    required this.price,
  });

  factory ServicePricing.fromJson(Map<String, dynamic> json) {
    return ServicePricing(
      id: json['id'] ?? 0,
      service_type_id: json['service_type_id'],
      propertyTypeId: json['property_type_id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      requestTypeId: json['request_type_id'] ?? 0,
      areaFrom: json['area_from'] ?? 0,
      areaTo: json['area_to'] ?? 0,
      price: json['price'] ?? '0.000',
    );
  }
}

class DocumentRequirement {

  final int id;
  final int propertyTypeId;
  final int serviceTypeId;
  final String documentName;
  final int isFile;

  DocumentRequirement({
    required this.id,
    required this.propertyTypeId,
    required this.serviceTypeId,
    required this.documentName,
    required this.isFile,
  });

  factory DocumentRequirement.fromJson(Map<String, dynamic> json) {
    return DocumentRequirement(
      id: json['id'] ?? 0,
      propertyTypeId: json['property_type_id'] ?? 0,
      serviceTypeId: json['service_type_id'] ?? 0,
      documentName: json['document_name'] ?? '',
      isFile: json['is_file'] ,
    );
  }
}

class Status {
  final int id;
  final String name;

  Status({
    required this.id,
    required this.name,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Setting {
  final String key;
  final String value;
  final int isFile;

  Setting({
    required this.key,
    required this.value,
    required this.isFile,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      isFile: json['is_file'] ?? 0,
    );
  }
}