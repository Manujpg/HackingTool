import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../widgets/alert.dart';

class BleMessageHandler {
  /// Verarbeitet eine eingehende BLE-Nachricht und zeigt entsprechende Toasts an.
  static void handleMessage(BuildContext context, String message) {
    String category = "";
    
    // Kategorisierung der Nachricht für den Switch-Case
    if (message.startsWith("Info:")) {
      category = "INFO";
    } else if (message.startsWith("Error:")) {
      category = "ERROR";
    } else if (message.startsWith("newSignal:")) {
      category = "NEW_SIGNAL";
    } else if (message.contains("findNewSignal")) {
      category = "FIND_SIGNAL";
    }

    switch (category) {
      case "INFO":
        showToastMessage(
          context: context,
          title: "System Information",
          description: message.replaceFirst("Info:", "").trim(),
          type: ToastificationType.info,
        );
        break;
      case "ERROR":
        showToastMessage(
          context: context,
          title: "Kritischer Fehler",
          description: message.replaceFirst("Error:", "").trim(),
          type: ToastificationType.error,
        );
        break;
      case "NEW_SIGNAL":
        showToastMessage(
          context: context,
          title: "Neues Signal",
          description: message.replaceFirst("newSignal:", "").trim(),
          type: ToastificationType.success,
        );
        break;
      case "FIND_SIGNAL":
        showToastMessage(
          context: context,
          title: "Signal-Suche",
          description: "Die Suche nach neuen Signalen wurde gestartet.",
          type: ToastificationType.info,
        );
        break;
      default:
        // Normale Nachrichten lösen keinen Toast aus
        break;
    }
  }
}
