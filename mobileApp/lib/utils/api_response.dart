import 'package:flutter/material.dart';
import 'notification.dart'; // your existing showMessage

/// Generic API response handler
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

  /// Automatically show message in UI
  void showMessageInUI(BuildContext context, {bool onlyOnError = false}) {
    if (!onlyOnError || (onlyOnError && !success)) {
      showMessage(context, message, type: success ? MessageType.success : MessageType.error);
    }
  }
}