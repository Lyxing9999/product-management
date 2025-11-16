import 'package:flutter/material.dart';
import 'notification.dart'; // your existing showMessage


class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic json) fromJsonData,
  }) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonData(json['data']) : null,
    );
  }

  /// New factory for error responses
  factory ApiResponse.error(String message) {
    return ApiResponse<T>(success: false, message: message, data: null);
  }

  /// New factory for success responses
  factory ApiResponse.success(T data, {String message = ''}) {
    return ApiResponse<T>(success: true, message: message, data: data);
  }

  void showMessageInUI(BuildContext context, {bool onlyOnError = false}) {
    if (!onlyOnError || (onlyOnError && !success)) {
      showMessage(context, message, type: success ? MessageType.success : MessageType.error);
    }
  }
}