import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

// Eine Funktion, die einen Dialog anzeigt
void showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onPressedOK,
  required VoidCallback onPressedCancel,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(onPressed: onPressedCancel, child: const Text('Abbrechen')),
        TextButton(onPressed: onPressedOK, child: const Text('OK')),
      ],
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}


// Eine einfache Funktion zum Anzeigen einer Toast-Meldung
void showToastMessage({
  required BuildContext context,
  required String title,
  required String description,
  ToastificationType type = ToastificationType.info, // Standard-Typ
  Alignment alignment = Alignment.topCenter, // Standard-Position
  Duration duration = const Duration(seconds: 3),
}) {
  // Zeige die Toast-Meldung an
  Toastification().show(
    context: context,
    title: Text(title),
    description: Text(description),
    type: type,
    alignment: alignment,
    autoCloseDuration: duration,
    // Optional: Ändere die Farbe basierend auf dem Typ
    style: ToastificationStyle.flatColored,
    backgroundColor: _getBackgroundColor(type),
  );
}

// Eine Hilfsfunktion, um die Farbe basierend auf dem Typ zu bestimmen
Color _getBackgroundColor(ToastificationType type) {
  switch (type) {
    case ToastificationType.success:
      return Colors.green[400]!;
    case ToastificationType.error:
      return Colors.red[400]!;
    case ToastificationType.warning:
      return Colors.orange[400]!;
    case ToastificationType.info:
    default:
      return Colors.blue[400]!;
  }
}
