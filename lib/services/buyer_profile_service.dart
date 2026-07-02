import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/buyer_address_model.dart';
import '../models/buyer_contact_model.dart';
import 'auth_service.dart';

class BuyerProfileData {
  final BuyerAddressModel address;
  final BuyerContactModel contact;
  final Map<String, dynamic>? user;

  const BuyerProfileData({
    required this.address,
    required this.contact,
    required this.user,
  });
}

class BuyerProfileService {
  final AuthService _authService = AuthService();

  Future<ApiResponse> getMyBuyerProfile() async {
    if (!_authService.hasVerifiedSession) {
      return _authService.verificationRequiredResponse();
    }

    final session = await _authService.restoreSession();
    final token = (session?['token'] ?? '').toString();
    if (token.isEmpty) {
      return const ApiResponse(
        statusCode: 401,
        body: '{"message":"Sesi tidak valid"}',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('${AuthService.serverBaseUrl}/api/auth/buyer-profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return const ApiResponse(
        statusCode: 500,
        body: '{"message":"Tidak dapat terhubung ke backend"}',
      );
    }
  }

  Future<ApiResponse> updateMyBuyerProfile({
    required BuyerAddressModel address,
    required BuyerContactModel contact,
  }) async {
    if (!_authService.hasVerifiedSession) {
      return _authService.verificationRequiredResponse();
    }

    final session = await _authService.restoreSession();
    final token = (session?['token'] ?? '').toString();
    if (token.isEmpty) {
      return const ApiResponse(
        statusCode: 401,
        body: '{"message":"Sesi tidak valid"}',
      );
    }

    try {
      final response = await http.patch(
        Uri.parse('${AuthService.serverBaseUrl}/api/auth/buyer-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': contact.email,
          'phone': contact.phone,
          'whatsapp': contact.whatsapp,
          'contactNote': contact.contactNote,
          'recipientName': address.recipientName,
          'addressLine': address.addressLine,
          'province': address.province,
          'city': address.city,
          'district': address.district,
          'subdistrict': address.subdistrict,
          'postalCode': address.postalCode,
          'landmark': address.landmark,
        }),
      );

      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return const ApiResponse(
        statusCode: 500,
        body: '{"message":"Tidak dapat terhubung ke backend"}',
      );
    }
  }

  Future<ApiResponse> updateMyBuyerAddress(BuyerAddressModel address) async {
    final token = await _restoreVerifiedToken();
    if (token == null) {
      return _authService.verificationRequiredResponse();
    }

    try {
      final response = await http.patch(
        Uri.parse(
          '${AuthService.serverBaseUrl}/api/auth/buyer-profile/address',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipientName': address.recipientName,
          'addressLine': address.addressLine,
          'province': address.province,
          'city': address.city,
          'district': address.district,
          'subdistrict': address.subdistrict,
          'postalCode': address.postalCode,
          'landmark': address.landmark,
        }),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return const ApiResponse(
        statusCode: 500,
        body: '{"message":"Tidak dapat terhubung ke backend"}',
      );
    }
  }

  Future<ApiResponse> updateMyBuyerContact(BuyerContactModel contact) async {
    final token = await _restoreVerifiedToken();
    if (token == null) {
      return _authService.verificationRequiredResponse();
    }

    try {
      final response = await http.patch(
        Uri.parse(
          '${AuthService.serverBaseUrl}/api/auth/buyer-profile/contact',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': contact.email,
          'phone': contact.phone,
          'whatsapp': contact.whatsapp,
          'contactNote': contact.contactNote,
        }),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return const ApiResponse(
        statusCode: 500,
        body: '{"message":"Tidak dapat terhubung ke backend"}',
      );
    }
  }

  BuyerProfileData parseProfile(String body) {
    final json = _decodeJsonObject(body);
    final profile = _decodeJsonObject(json['profile']);
    return BuyerProfileData(
      address: BuyerAddressModel.fromJson(profile),
      contact: BuyerContactModel.fromJson(profile),
      user: _decodeNullableUser(json['user']),
    );
  }

  String parseMessage(String body) {
    final json = _decodeJsonObject(body);
    return (json['message'] ?? 'Terjadi kesalahan').toString();
  }

  Future<void> syncSessionUserFromResponse(String body) async {
    final json = _decodeJsonObject(body);
    final user = _decodeNullableUser(json['user']);
    if (user != null) {
      await _authService.updateSessionUser(
        user,
        sessionState: SessionState.verified,
      );
    }
  }

  Future<String?> _restoreVerifiedToken() async {
    if (!_authService.hasVerifiedSession) {
      return null;
    }

    final session = await _authService.restoreSession();
    final token = (session?['token'] ?? '').toString();
    return token.isEmpty ? null : token;
  }

  Map<String, dynamic> _decodeJsonObject(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic>? _decodeNullableUser(dynamic raw) {
    final user = _decodeJsonObject(raw);
    return user.isEmpty ? null : user;
  }
}
