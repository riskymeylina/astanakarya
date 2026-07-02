import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final int purchaseId;
  final int buyerId;
  final int propertyId;
  final String propertyName;
  final double propertyPrice;
  final String? paymentMethod;
  final String? paymentProofUrl;
  final String paymentStatus;
  final String? issuedAt;
  final String? dueDate;
  final String createdAt;
  final String updatedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.purchaseId,
    required this.buyerId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyPrice,
    this.paymentMethod,
    this.paymentProofUrl,
    required this.paymentStatus,
    this.issuedAt,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int? ?? json['id_invoice'] as int? ?? 0,
      invoiceNumber: json['invoiceNumber'] as String? ?? json['invoice_number'] as String? ?? '',
      purchaseId: json['purchaseId'] as int? ?? json['purchase_id'] as int? ?? 0,
      buyerId: json['buyerId'] as int? ?? json['buyer_id'] as int? ?? 0,
      propertyId: json['propertyId'] as int? ?? json['property_id'] as int? ?? 0,
      propertyName: json['propertyName'] as String? ?? json['property_name'] as String? ?? '',
      propertyPrice: (json['propertyPrice'] ?? json['property_price'] as num? ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] as String? ?? json['payment_method'] as String?,
      paymentProofUrl: json['paymentProofUrl'] as String? ?? json['payment_proof_url'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? json['payment_status'] as String? ?? 'pending',
      issuedAt: json['issuedAt'] as String? ?? json['issued_at'] as String?,
      dueDate: json['dueDate'] as String? ?? json['due_date'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
    );
  }
}

class AdminInvoiceService {
  static const String _baseUrl = '/api/invoices';

  final String _serverBaseUrl = AuthService.serverBaseUrl;

  Future<http.Response> getInvoices({
    String? paymentStatus,
    String? from,
    String? to,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['payment_status'] = paymentStatus;
      }
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (to != null && to.isNotEmpty) queryParams['to'] = to;

      final uri = Uri.parse('$_serverBaseUrl$_baseUrl').replace(queryParameters: queryParams);

      return await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      return http.Response(
        jsonEncode({'error': e.toString()}),
        500,
      );
    }
  }

  Future<http.Response> getInvoiceDetail(int invoiceId) async {
    try {
      final token = _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      return await http
          .get(
            Uri.parse('$_serverBaseUrl$_baseUrl/$invoiceId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      return http.Response(
        jsonEncode({'error': e.toString()}),
        500,
      );
    }
  }

  List<InvoiceModel> parseInvoices(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final invoices = json['invoices'] as List<dynamic>? ?? [];
      return invoices.map((i) => InvoiceModel.fromJson(i as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  InvoiceModel? parseInvoiceDetail(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final invoice = json['invoice'] as Map<String, dynamic>?;
      if (invoice == null) return null;
      return InvoiceModel.fromJson(invoice);
    } catch (e) {
      return null;
    }
  }

  String parseMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String? ?? 'Operasi gagal';
    } catch (e) {
      return 'Terjadi kesalahan';
    }
  }

  String? _getToken() {
    final session = AuthService().getSession();
    final token = (session?['token'] ?? '').toString();
    return token.isEmpty ? null : token;
  }
}
