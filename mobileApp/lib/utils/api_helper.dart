import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_response.dart';

class ApiHelper {
  static ApiResponse<T> parseResponse<T>(
      http.Response response, T Function(dynamic json) fromJson) {
    final Map<String, dynamic> jsonMap = jsonDecode(response.body);

    try {
      final bool success = jsonMap['success'] ?? false;
      final String message = jsonMap['message'] ?? '';
      final data = jsonMap['data'] != null ? fromJson(jsonMap['data']) : null;

      return ApiResponse<T>(
        success: success,
        message: message,
        data: data,
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse response: $e',
        data: null,
      );
    }
  }
}