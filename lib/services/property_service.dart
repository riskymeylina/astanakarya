import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/property_model.dart';
import 'auth_service.dart';

class PropertyService {
  static String get _apiBaseUrl =>
      '${AuthService.serverBaseUrl}/api/properties';

  Future<ApiResponse> getProperties({
    String? query,
    String? category,
    String? brand,
    int? minPrice,
    int? maxPrice,
    String? status,
    String? sortBy,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (query != null && query.trim().isNotEmpty) {
        queryParameters['q'] = query.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        queryParameters['category'] = category.trim();
      }
      if (brand != null && brand.trim().isNotEmpty) {
        queryParameters['brand'] = brand.trim();
      }
      if (minPrice != null) queryParameters['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParameters['maxPrice'] = maxPrice.toString();
      if (status != null && status.trim().isNotEmpty) {
        queryParameters['status'] = status.trim();
      }
      if (sortBy != null && sortBy.trim().isNotEmpty) {
        queryParameters['sortBy'] = sortBy.trim();
      }

      final uri = Uri.parse(_apiBaseUrl).replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final response = await http.get(uri);
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return ApiResponse(
        statusCode: 500,
        body: jsonEncode({'message': 'Tidak dapat terhubung ke backend'}),
      );
    }
  }

  Future<ApiResponse> getPropertyFilters() async {
    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/filters'));
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return ApiResponse(
        statusCode: 500,
        body: jsonEncode({'message': 'Tidak dapat terhubung ke backend'}),
      );
    }
  }

  Future<ApiResponse> getPropertyDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/$id'));
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return ApiResponse(
        statusCode: 500,
        body: jsonEncode({'message': 'Tidak dapat terhubung ke backend'}),
      );
    }
  }

  Future<ApiResponse> updatePropertyStatus(int propertyId, String status) async {
    final token = AuthService().getSession()?['token']?.toString() ?? '';
    if (token.isEmpty) {
      return ApiResponse(
        statusCode: 401,
        body: jsonEncode({'message': 'Sesi tidak ditemukan'}),
      );
    }

    try {
      final uri = Uri.parse('$_apiBaseUrl/$propertyId/status');
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );
      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } catch (_) {
      return ApiResponse(
        statusCode: 500,
        body: jsonEncode({'message': 'Tidak dapat terhubung ke backend'}),
      );
    }
  }

  List<PropertyModel> parseProperties(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }

    final rawItems = decoded['properties'];
    if (rawItems is! List) {
      return const [];
    }

    final properties = <PropertyModel>[];
    for (final item in rawItems.whereType<Map>()) {
      try {
        properties.add(PropertyModel.fromJson(Map<String, dynamic>.from(item)));
      } on FormatException {
        continue;
      }
    }
    return properties;
  }

  PropertyModel parsePropertyDetail(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['property'] is! Map) {
        throw const FormatException('Data properti tidak valid');
      }

      return PropertyModel.fromJson(
        Map<String, dynamic>.from(decoded['property'] as Map),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Data properti tidak valid');
    }
  }

  PropertyFilterOptions parsePropertyFilters(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['filters'] is! Map) {
        return const PropertyFilterOptions();
      }

      final filters = Map<String, dynamic>.from(decoded['filters'] as Map);
      return PropertyFilterOptions(
        brands: _parseStringList(filters['brands']),
        sizes: _parseStringList(filters['sizes']),
      );
    } catch (_) {
      return const PropertyFilterOptions();
    }
  }

  List<String> _parseStringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
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

  String formatPrice(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }
}

class PropertyFilterOptions {
  final List<String> brands;
  final List<String> sizes;

  const PropertyFilterOptions({this.brands = const [], this.sizes = const []});
}

class ApiResponse {
  final int statusCode;
  final String body;

  const ApiResponse({required this.statusCode, required this.body});
}
