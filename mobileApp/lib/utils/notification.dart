import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

enum MessageType { success, error, warning, info }

void showMessage(BuildContext context, String message, {MessageType type = MessageType.info}) {
  Color bgColor;
  Icon icon;

  switch (type) {
    case MessageType.success:
      bgColor = Colors.green;
      icon = const Icon(Icons.check_circle, color: Colors.white);
      break;
    case MessageType.error:
      bgColor = Colors.red;
      icon = const Icon(Icons.error, color: Colors.white);
      break;
    case MessageType.warning:
      bgColor = Colors.orange;
      icon = const Icon(Icons.warning, color: Colors.white);
      break;
    case MessageType.info:
    default:
      bgColor = Colors.blue;
      icon = const Icon(Icons.info, color: Colors.white);
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Flushbar(
      messageText: Text(message, style: const TextStyle(color: Colors.white)),
      icon: icon,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: bgColor,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  });
}