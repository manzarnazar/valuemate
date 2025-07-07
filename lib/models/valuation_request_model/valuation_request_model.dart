class ValuationRequest {
  final int? valuation_request_id;
  final int companyId;
  final int userId;
  final int? propertyTypeId;
  final int? serviceTypeId;
  final int? requestTypeId;
  final int locationId;

  final int area;

  final String reference;

  ValuationRequest({
    this.valuation_request_id,
    required this.companyId,
    required this.userId,
    this.propertyTypeId,
    this.serviceTypeId,
    this.requestTypeId,
    required this.locationId,

    required this.area,

    required this.reference,
  });

  Map<String, String> toJson() {
  return {
    'valuation_request_id': valuation_request_id.toString(),
    'company_id': companyId.toString(),
    'user_id': userId.toString(),
    'property_type_id': propertyTypeId?.toString() ?? '',
    'service_type_id': serviceTypeId?.toString() ?? '',
    'request_type_id': requestTypeId?.toString() ?? '',
    'location_id': locationId.toString(),

    'area': area.toString(),

    'reference': reference,
  };
}

}