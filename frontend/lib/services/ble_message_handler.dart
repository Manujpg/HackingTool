import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../widgets/alert.dart';
import '../model/signal.dart';
import 'signal_repository.dart';

import '../model/scan_freq.dart';
import 'scan_freq_repository.dart';

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
        final rawData = message.replaceFirst("newSignal:", "").trim();
        final signal = Signal.fromRawString(rawData);
        SignalRepository.instance.addSignal(signal);
        break;
      case "FIND_SIGNAL":
        final rawData = message.replaceFirst("findNewSignal:", "").trim();
        if (rawData.isNotEmpty) {
          final hit = ScanFreq.fromRawString(rawData);
          ScanFreqRepository.instance.addHit(hit);
        } else {
          // showToastMessage(
          //   context: context,
          //   title: "Signal-Suche",
          //   description: "Die Suche nach neuen Signalen wurde gestartet.",
          //   type: ToastificationType.info,
          // );
        }
        break;
      default:
        // Normale Nachrichten lösen keinen Toast aus
        break;
    }
  }
}
