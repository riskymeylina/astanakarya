class PurchaseOrderModel {
  final int id;
  final int buyerUserId;
  final int propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String? propertyThumbnailUrl;
  final double propertyPrice;
  final String paymentMethod;
  final String? paymentAccountNumber;
  final String? paymentAccountName;
  final String? paymentBankNote;
  final double paymentAmount;
  final String? paymentDueAt;
  final String? cancelledAt;
  final String buyerNameSnapshot;
  final String? buyerPhoneSnapshot;
  final String? buyerAddressSnapshot;
  final String? notes;
  final String status;
  final String? paymentProofUrl;
  final String? paymentProofUploadedAt;
  final int? processedByUserId;
  final String? processedByName;
  final String? rejectionReason;
  final String? processedAt;
  final String? createdAt;
  final String? updatedAt;

  const PurchaseOrderModel({
    required this.id,
    required this.buyerUserId,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.propertyThumbnailUrl,
    required this.propertyPrice,
    required this.paymentMethod,
    required this.paymentAccountNumber,
    required this.paymentAccountName,
    required this.paymentBankNote,
    required this.paymentAmount,
    required this.paymentDueAt,
    required this.cancelledAt,
    required this.buyerNameSnapshot,
    required this.buyerPhoneSnapshot,
    required this.buyerAddressSnapshot,
    required this.notes,
    required this.status,
    required this.paymentProofUrl,
    required this.paymentProofUploadedAt,
    required this.processedByUserId,
    required this.processedByName,
    required this.rejectionReason,
    required this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    final id = _toInt(json['id'] ?? json['id_purchase']);
    final buyerUserId = _toInt(json['buyerUserId'] ?? json['buyer_user_id']);
    final propertyId = _toInt(json['propertyId'] ?? json['property_id']);

    if (id == null || buyerUserId == null || propertyId == null) {
      throw const FormatException('Data pemesanan tidak valid');
    }

    return PurchaseOrderModel(
      id: id,
      buyerUserId: buyerUserId,
      propertyId: propertyId,
      propertyTitle: _toText(json['propertyTitle']),
      propertyLocation: _toText(json['propertyLocation']),
      propertyThumbnailUrl: _toOptionalText(json['propertyThumbnailUrl']),
      propertyPrice: _toDouble(json['propertyPrice']),
      paymentMethod: _toText(json['paymentMethod']),
      paymentAccountNumber: _toOptionalText(json['paymentAccountNumber']),
      paymentAccountName: _toOptionalText(json['paymentAccountName']),
      paymentBankNote: _toOptionalText(json['paymentBankNote']),
      paymentAmount: _toDouble(json['paymentAmount']),
      paymentDueAt: _toOptionalText(json['paymentDueAt']),
      cancelledAt: _toOptionalText(json['cancelledAt']),
      buyerNameSnapshot: _toText(json['buyerNameSnapshot']),
      buyerPhoneSnapshot: _toOptionalText(json['buyerPhoneSnapshot']),
      buyerAddressSnapshot: _toOptionalText(json['buyerAddressSnapshot']),
      notes: _toOptionalText(json['notes']),
      status: _toText(json['status']),
      paymentProofUrl: _toOptionalText(json['paymentProofUrl']),
      paymentProofUploadedAt: _toOptionalText(json['paymentProofUploadedAt']),
      processedByUserId: _toInt(json['processedByUserId']),
      processedByName: _toOptionalText(json['processedByName']),
      rejectionReason: _toOptionalText(json['rejectionReason']),
      processedAt: _toOptionalText(json['processedAt']),
      createdAt: _toOptionalText(json['createdAt']),
      updatedAt: _toOptionalText(json['updatedAt']),
    );
  }

  // Getter alias untuk TransactionsPage & SalesReportPage
  String? get buyerName => buyerNameSnapshot.isNotEmpty ? buyerNameSnapshot : null;
  String? get invoiceNumber => 'INV-$id';
  double? get totalPrice => paymentAmount > 0 ? paymentAmount : propertyPrice;

  // Modifikasi & Penambahan Alias Baru Agar Sinkron dengan Halaman Detail & Sales Report
  String? get propertyType => null; // Kembalikan null jika tipe tidak ada di backend, atau pasang default String jika perlu
  String? get propertyImageUrl => propertyThumbnailUrl;
  String? get propertyLandArea => null;
  String? get propertyBuildingArea => null;
  String? get buyerEmail => null;
  String? get buyerAddress => buyerAddressSnapshot;
  String? get bankName => paymentBankNote;
  String? get bankAccountNumber => paymentAccountNumber;
  String? get bankAccountName => paymentAccountName;
  String? get referenceNumber => null;
  String? get paymentProofFilename => paymentProofUrl != null ? 'bukti_transfer_$id.png' : null;
  String? get confirmedAt => status == 'confirmed' ? processedAt : null;
  String? get reviewedAt => processedAt;
  String? get rejectedAt => status == 'rejected' ? processedAt : null;
  String? get verifiedBy => processedByName;

  bool get isPendingPayment => status == 'pending_payment';
  bool get isPaymentUploaded => status == 'payment_uploaded';
  bool get isPaymentReview => status == 'payment_review';
  bool get isConfirmed => status == 'confirmed';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get canUploadProof => isPendingPayment || isRejected;
  bool get isActive => !isConfirmed && !isRejected && !isCancelled;
  double get payableAmount => paymentAmount > 0 ? paymentAmount : propertyPrice;

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return null;
      }
      return int.tryParse(normalized);
    }

    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  static String _toText(dynamic value) => value?.toString() ?? '';

  static String? _toOptionalText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}