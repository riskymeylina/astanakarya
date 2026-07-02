import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  static String get _apiBaseUrl =>
      '${AuthService.serverBaseUrl}/api/notifications';

  Future<ApiResponse> getNotifications({String? search}) async {
    final token = _getToken();
    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final normalizedSearch = search?.trim();
      final uri = Uri.parse(_apiBaseUrl).replace(
        queryParameters: normalizedSearch == null || normalizedSearch.isEmpty
            ? null
            : {'search': normalizedSearch},
      );
      final response = await http.get(uri, headers: _headers(token));
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> getNotificationDetail(int notificationId) async {
    final token = _getToken();
    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/$notificationId'),
        headers: _headers(token),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> markAsRead(int notificationId) async {
    final token = _getToken();
    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.patch(
        Uri.parse('$_apiBaseUrl/$notificationId/read'),
        headers: _headers(token),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> deleteNotification(int notificationId) async {
    final token = _getToken();
    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/$notificationId'),
        headers: _headers(token),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  List<NotificationModel> parseNotifications(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }

    final rawItems = decoded['notifications'];
    if (rawItems is! List) {
      return const [];
    }

    final notifications = <NotificationModel>[];
    for (final item in rawItems.whereType<Map>()) {
      try {
        notifications.add(
          NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } on FormatException {
        continue;
      }
    }
    return notifications;
  }

  NotificationModel parseNotification(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['notification'] is! Map) {
        throw const FormatException('Data notifikasi tidak valid');
      }

      return NotificationModel.fromJson(
        Map<String, dynamic>.from(decoded['notification'] as Map),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Data notifikasi tidak valid');
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

  ApiResponse _unauthorizedResponse() => ApiResponse(
    statusCode: 401,
    body: jsonEncode({'message': 'Sesi login tidak ditemukan'}),
  );
}
