class BuyerAddressModel {
  final String recipientName;
  final String addressLine;
  final String province;
  final String city;
  final String district;
  final String subdistrict;
  final String postalCode;
  final String landmark;

  const BuyerAddressModel({
    required this.recipientName,
    required this.addressLine,
    required this.province,
    required this.city,
    required this.district,
    required this.subdistrict,
    required this.postalCode,
    required this.landmark,
  });

  factory BuyerAddressModel.fromJson(Map<String, dynamic> json) {
    return BuyerAddressModel(
      recipientName: (json['recipientName'] ?? '').toString(),
      addressLine: (json['addressLine'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      subdistrict: (json['subdistrict'] ?? '').toString(),
      postalCode: (json['postalCode'] ?? '').toString(),
      landmark: (json['landmark'] ?? '').toString(),
    );
  }
}
