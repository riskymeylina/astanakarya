import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/property_preferences_model.dart';
import 'auth_service.dart';

class PropertyPreferencesService {
  static String get _apiBaseUrl =>
      '${AuthService.serverBaseUrl}/api/auth/property-preferences';

  Future<ApiResponse> getMyPropertyPreferences() async {
    final token = _getToken();
    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.get(
        Uri.parse(_apiBaseUrl),
        headers: _headers(token),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> updateMyPropertyPreferences(
    PropertyPreferencesModel preferences,
  ) async {
    final token = _getToken();
    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.patch(
        Uri.parse(_apiBaseUrl),
        headers: _headers(token),
        body: jsonEncode(preferences.toJson()),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  PropertyPreferencesModel parsePreferences(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['preferences'] is! Map) {
        return const PropertyPreferencesModel.empty();
      }

      return PropertyPreferencesModel.fromJson(
        Map<String, dynamic>.from(decoded['preferences'] as Map),
      );
    } catch (_) {
      return const PropertyPreferencesModel.empty();
    }
  }

  String parseMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      return 'Terjadi kesalahan';
    }

    return 'Terjadi kesalahan';
  }

  String? _getToken() {
    final session = AuthService().getSession();
    if ((session?['sessionState'] ?? '').toString() != SessionState.verified) {
      return null;
    }

    final token = (session?['token'] ?? '').toString();
    return token.isEmpty ? null : token;
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  ApiResponse _networkErrorResponse() => ApiResponse(
    statusCode: 500,
    body: jsonEncode({'message': 'Tidak dapat terhubung ke backend'}),
  );

  ApiResponse _unauthorizedResponse() {
    final session = AuthService().getSession();
    if ((session?['sessionState'] ?? '').toString() ==
        SessionState.cachedUnverified) {
      return AuthService().verificationRequiredResponse();
    }

    return ApiResponse(
      statusCode: 401,
      body: jsonEncode({'message': 'Sesi login tidak ditemukan'}),
    );
  }
}
