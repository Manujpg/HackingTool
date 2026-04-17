class ScanFreq {
  final double frequency;
  final int rssi;
  final DateTime timestamp;

  ScanFreq({
    required this.frequency,
    required this.rssi,
    required this.timestamp,
  });

  /// Erstellt ein ScanFreq Objekt aus dem BLE-String Format:
  /// "Frequenz: 430.00 MHz | RSSI: -59"
  factory ScanFreq.fromRawString(String message) {
    try {
      final regExp = RegExp(r"Frequenz:\s+([\d.]+)\s+MHz\s+\|\s+RSSI:\s+(-?[\d.]+)");
      final match = regExp.firstMatch(message);

      if (match != null) {
        return ScanFreq(
          frequency: double.tryParse(match.group(1) ?? '0') ?? 0.0,
          rssi: int.tryParse(match.group(2) ?? '0') ?? 0,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      // ignore
    }
    return ScanFreq(frequency: 0, rssi: 0, timestamp: DateTime.now());
  }
}
