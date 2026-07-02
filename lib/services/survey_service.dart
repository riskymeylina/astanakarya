import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/survey_request_model.dart';
import 'auth_service.dart';

class SurveyService {
  static String get _apiBaseUrl =>
      '${AuthService.serverBaseUrl}/api/surveys';

  // ═════════════════════════════════════════════════════════════════════
  // GET MY SURVEY REQUESTS
  // ═════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getMySurveyRequests() async {
    final token = _getToken();

    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/my-requests'),
        headers: _headers(token),
      );

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // GET MARKETING SURVEY REQUESTS
  // ═════════════════════════════════════════════════════════════════════
  Future<ApiResponse> getMarketingSurveyRequests({
    String? status,
  }) async {
    final token = _getToken(requireVerifiedSession: true);

    if (token == null) {
      return _unauthorizedResponse(
        requireVerifiedSession: true,
      );
    }

    try {
      final uri = Uri.parse(
        '$_apiBaseUrl/requests',
      ).replace(
        queryParameters:
            status == null || status.trim().isEmpty
                ? null
                : {
                  'status': status.trim(),
                },
      );

      final response = await http.get(
        uri,
        headers: _headers(token),
      );

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // CREATE SURVEY REQUEST
  // ═════════════════════════════════════════════════════════════════════
  Future<ApiResponse> createSurveyRequest({
    required int propertyId,
    required String requestedDate,
    String? requestedTime,
    String? notes,
  }) async {
    final token = _getToken();

    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: _headers(token),
        body: jsonEncode({
          'propertyId': propertyId,
          'requestedDate': requestedDate,
          'requestedTime': requestedTime,
          'notes': notes,
        }),
      );

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // UPDATE SURVEY STATUS
  // ═════════════════════════════════════════════════════════════════════
  Future<ApiResponse> updateSurveyStatus({
    required int surveyId,
    required String status,
    String? approvedScheduleDate,
    String? approvedScheduleTime,
    String? rejectionReason,
  }) async {
    final token = _getToken(
      requireVerifiedSession: true,
    );

    if (token == null) {
      return _unauthorizedResponse(
        requireVerifiedSession: true,
      );
    }

    try {
      final response = await http.patch(
        Uri.parse('$_apiBaseUrl/$surveyId/status'),
        headers: _headers(token),
        body: jsonEncode({
          'status': status,
          'approvedScheduleDate': approvedScheduleDate,
          'approvedScheduleTime': approvedScheduleTime,
          'rejectionReason': rejectionReason,
        }),
      );

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // CANCEL SURVEY REQUEST
  // ═════════════════════════════════════════════════════════════════════
  Future<ApiResponse> cancelSurveyRequest(int surveyId) async {
    final token = _getToken();

    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.patch(
        Uri.parse('$_apiBaseUrl/$surveyId/cancel'),
        headers: _headers(token),
      );

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // UPDATE SURVEY REQUEST (EDIT)
  // ═════════════════════════════════════════════════════════════════════
  Future<ApiResponse> updateSurveyRequest({
    required int surveyId,
    required String requestedDate,
    String? requestedTime,
    String? notes,
  }) async {
    final token = _getToken();

    if (token == null) {
      return _unauthorizedResponse();
    }

    try {
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/$surveyId'),
        headers: _headers(token),
        body: jsonEncode({
          'requestedDate': requestedDate,
          'requestedTime': requestedTime,
          'notes': notes,
        }),
      );

      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return _networkErrorResponse();
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // PARSE SURVEY LIST
  // ═════════════════════════════════════════════════════════════════════
  List<SurveyRequestModel> parseSurveys(String body) {
    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      return const [];
    }

    final rawItems = decoded['surveys'];

    if (rawItems is! List) {
      return const [];
    }

    final surveys = <SurveyRequestModel>[];

    for (final item in rawItems.whereType<Map>()) {
      try {
        surveys.add(
          SurveyRequestModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      } on FormatException {
        continue;
      }
    }

    return surveys;
  }

  // ═════════════════════════════════════════════════════════════════════
  // PARSE SINGLE SURVEY
  // ═════════════════════════════════════════════════════════════════════
  SurveyRequestModel parseSurvey(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic> ||
          decoded['survey'] is! Map) {
        throw const FormatException(
          'Data survei tidak valid',
        );
      }

      return SurveyRequestModel.fromJson(
        Map<String, dynamic>.from(
          decoded['survey'] as Map,
        ),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(
        'Data survei tidak valid',
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // PARSE MESSAGE
  // ═════════════════════════════════════════════════════════════════════
  String parseMessage(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic> &&
          decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      return 'Terjadi kesalahan';
    }

    return 'Terjadi kesalahan';
  }

  // ═════════════════════════════════════════════════════════════════════
  // TOKEN
  // ═════════════════════════════════════════════════════════════════════
  String? _getToken({
    bool requireVerifiedSession = false,
  }) {
    final session = AuthService().getSession();

    final state =
        (session?['sessionState'] ?? '').toString();

    if (requireVerifiedSession &&
        state != SessionState.verified) {
      return null;
    }

    final token =
        (session?['token'] ?? '').toString();

    return token.isEmpty ? null : token;
  }

  // ═════════════════════════════════════════════════════════════════════
  // HEADERS
  // ═════════════════════════════════════════════════════════════════════
  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ═════════════════════════════════════════════════════════════════════
  // NETWORK ERROR
  // ═════════════════════════════════════════════════════════════════════
  ApiResponse _networkErrorResponse() => ApiResponse(
    statusCode: 500,
    body: jsonEncode({
      'message': 'Tidak dapat terhubung ke backend',
    }),
  );

  // ═════════════════════════════════════════════════════════════════════
  // UNAUTHORIZED
  // ═════════════════════════════════════════════════════════════════════
  ApiResponse _unauthorizedResponse({
    bool requireVerifiedSession = false,
  }) {
    final session = AuthService().getSession();

    final state =
        (session?['sessionState'] ?? '').toString();

    if (requireVerifiedSession &&
        state == SessionState.cachedUnverified) {
      return AuthService()
          .verificationRequiredResponse();
    }

    return ApiResponse(
      statusCode: 401,
      body: jsonEncode({
        'message': 'Sesi login tidak ditemukan',
      }),
    );
  }
}