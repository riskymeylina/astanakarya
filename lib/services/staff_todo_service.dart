import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class StaffTodoService {
  static String get _apiBaseUrl => '${AuthService.serverBaseUrl}/api/todos';

  Future<ApiResponse> getTodos({String? filter}) async {
    final token = _getToken();
    if (token == null) return _unauthorizedResponse();

    try {
      final uri = Uri.parse(_apiBaseUrl).replace(
        queryParameters: filter != null && filter.isNotEmpty ? {'filter': filter} : null,
      );
      final response = await http.get(uri, headers: _headers(token));
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> createTodo(String title, String description, String dueDate) async {
    final token = _getToken();
    if (token == null) return _unauthorizedResponse();

    try {
      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'description': description,
          'due_date': dueDate.isNotEmpty ? dueDate : null,
        }),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> updateTodoStatus(int id, String status) async {
    final token = _getToken();
    if (token == null) return _unauthorizedResponse();

    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/$id'),
        headers: _headers(token),
        body: jsonEncode({'status': status}),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  Future<ApiResponse> deleteTodo(int id) async {
    final token = _getToken();
    if (token == null) return _unauthorizedResponse();

    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/$id'),
        headers: _headers(token),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  List<Map<String, dynamic>> parseTodos(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
        return [];
      }
      return List<Map<String, dynamic>>.from(decoded['data']);
    } catch (_) {
      return [];
    }
  }

  String parseMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
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
