class HistoryModel {
  final int id;
  final String companyName;
  final String userName;
  final String propertyType;
  final String serviceType;
  final String requestType;
  final String location;
  final String servicePricing;
  final String area;
  final String totalAmount;
  final String status;
  final int status_id;
  final String reference;
  final String createdAtDate;
  final String createdAtTime;
  final String paymentStatus;

  HistoryModel({
    required this.id,
    required this.companyName,
    required this.userName,
    required this.propertyType,
    required this.serviceType,
    required this.requestType,
    required this.location,
    required this.servicePricing,
    required this.area,
    required this.totalAmount,
    required this.status,
    required this.status_id,
    required this.reference,
    required this.createdAtDate,
    required this.createdAtTime,
    required this.paymentStatus,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      companyName: json['company_name'],
      userName: json['user_name'],
      propertyType: json['property_type'],
      serviceType: json['service_type'],
      requestType: json['request_type'],
      location: json['location'],
      servicePricing: json['service_pricing'],
      area: json['area'],
      totalAmount: json['total_amount'],
      status: json['status'],
      status_id: json['status_id'],
      reference: json['reference'],
      createdAtDate: json['created_at_date'],
      createdAtTime: json['created_at_time'],
      paymentStatus: json['payment_status'],
    );
  }
}
