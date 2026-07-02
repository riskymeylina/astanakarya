class BuyerContactModel {
  final String email;
  final String phone;
  final String whatsapp;
  final String contactNote;

  const BuyerContactModel({
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.contactNote,
  });

  factory BuyerContactModel.fromJson(Map<String, dynamic> json) {
    return BuyerContactModel(
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      whatsapp: (json['whatsapp'] ?? '').toString(),
      contactNote: (json['contactNote'] ?? '').toString(),
    );
  }
}
