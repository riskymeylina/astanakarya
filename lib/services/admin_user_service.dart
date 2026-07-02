import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin_models.dart';
import 'auth_service.dart';

class AdminUserService {
  static String get _apiBaseUrl =>
      '${AuthService.serverBaseUrl}/api/admin/users';

  Future<ApiResponse> getUsers({String? role}) async {
    final uri = Uri.parse(_apiBaseUrl).replace(
      queryParameters: (role?.trim().isNotEmpty ?? false)
          ? {'role': role!.trim()}
          : null,
    );
    return _request('GET', uri);
  }

  Future<ApiResponse> updateUserRole({
    required int id,
    required String role,
  }) async {
    return _request(
      'PATCH',
      Uri.parse('$_apiBaseUrl/$id/role'),
      body: {'role': role},
    );
  }

  Future<ApiResponse> deleteUser(int id) async =>
      _request('DELETE', Uri.parse('$_apiBaseUrl/$id'));

  Future<ApiResponse> createStaff({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _request(
      'POST',
      Uri.parse(_apiBaseUrl),
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<ApiResponse> updateStaff({
    required int id,
    required String name,
    required String email,
    required String phone,
    required bool isActive,
  }) async {
    return _request(
      'PATCH',
      Uri.parse('$_apiBaseUrl/$id'),
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'isActive': isActive,
      },
    );
  }

  List<AdminUserModel> parseUsers(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic> || decoded['users'] is! List)
      return const [];
    return (decoded['users'] as List)
        .whereType<Map>()
        .map((item) => AdminUserModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  String parseMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null)
        return decoded['message'].toString();
    } catch (_) {
      return 'Terjadi kesalahan';
    }
    return 'Terjadi kesalahan';
  }

  Future<ApiResponse> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    final token = _token();
    if (token == null) return _unauthorizedResponse();

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final encoded = body == null ? null : jsonEncode(body);
      final response = switch (method) {
        'POST' => await http.post(uri, headers: headers, body: encoded),
        'PATCH' => await http.patch(uri, headers: headers, body: encoded),
        'DELETE' => await http.delete(uri, headers: headers),
        _ => await http.get(uri, headers: headers),
      };
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return ApiResponse(
        statusCode: 500,
        body: jsonEncode({'message': 'Tidak dapat terhubung ke backend'}),
      );
    }
  }

  String? _token() {
    final session = AuthService().getSession();
    if ((session?['sessionState'] ?? '').toString() != SessionState.verified) {
      return null;
    }
    if ((session?['role'] ?? '').toString() != UserRoles.admin) {
      return null;
    }
    final token = (session?['token'] ?? '').toString();
    return token.isEmpty ? null : token;
  }

  ApiResponse _unauthorizedResponse() => ApiResponse(
    statusCode: 401,
    body: jsonEncode({'message': 'Sesi admin tidak ditemukan'}),
  );
}
