import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _backendUrlPreferenceKey = 'backend_base_url';
  static const String _webBaseUrl = 'https://pui.surly.my.id';
  static const String _physicalMobileBaseUrl = 'https://pui.surly.my.id';
  static const String _emulatorMobileBaseUrl = 'https://pui.surly.my.id';
  static const String _dartDefineBaseUrl = String.fromEnvironment(
    'PUIMEY_API_BASE_URL',
    defaultValue: '',
  );

  static String _mobileBaseUrl = _emulatorMobileBaseUrl;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (kIsWeb) {
      _initialized = true;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedBaseUrl =
        prefs.getString(_backendUrlPreferenceKey)?.trim() ?? '';
    if (savedBaseUrl.isNotEmpty) {
      _mobileBaseUrl = _normalizeBaseUrl(savedBaseUrl);
      _initialized = true;
      return;
    }

    if (_dartDefineBaseUrl.trim().isNotEmpty) {
      _mobileBaseUrl = _normalizeBaseUrl(_dartDefineBaseUrl);
      _initialized = true;
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    _mobileBaseUrl = androidInfo.isPhysicalDevice
        ? _physicalMobileBaseUrl
        : _emulatorMobileBaseUrl;
    _initialized = true;
  }

  static String get serverBaseUrl => kIsWeb ? _webBaseUrl : _mobileBaseUrl;

  static String get authApiBaseUrl => '$serverBaseUrl/api/auth';

  static Future<void> saveMobileBaseUrl(String baseUrl) async {
    final normalized = _normalizeBaseUrl(baseUrl);
    if (kIsWeb) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendUrlPreferenceKey, normalized);
    _mobileBaseUrl = normalized;
  }

  static Future<void> clearMobileBaseUrl() async {
    if (kIsWeb) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backendUrlPreferenceKey);

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    _mobileBaseUrl = androidInfo.isPhysicalDevice
        ? _physicalMobileBaseUrl
        : _emulatorMobileBaseUrl;
  }

  static Future<bool> testMobileBaseUrl(String baseUrl) async {
    final normalized = _normalizeBaseUrl(baseUrl);
    try {
      final response = await http
          .get(Uri.parse('$normalized/api/health'))
          .timeout(const Duration(seconds: 8));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) {
      return _emulatorMobileBaseUrl;
    }

    if (!trimmed.contains('://')) {
      return 'http://$trimmed';
    }

    return trimmed;
  }
}
