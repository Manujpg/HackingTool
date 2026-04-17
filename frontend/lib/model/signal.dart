class Signal {
  final double high;
  final double low;
  final double frequenz;
  final int modulation;
  final double rxBw; // Auf double geändert, da der String 812.50 liefert

  // Konstruktor mit benannten Parametern
  Signal({
    required this.high,
    required this.low,
    required this.frequenz,
    required this.modulation,
    required this.rxBw,
  });

  // Getter-Methoden
  double get highValue => high;
  double get lowValue => low;
  double get frequencyValue => frequenz;
  int get modulationValue => modulation;
  double get rxBwValue => rxBw;

  /// Erstellt ein Signal aus dem BLE-String Format:
  /// "981152,42838 f: 433.00, m: 0, r: 812.50"
  factory Signal.fromRawString(String message) {
    try {
      // Regex zum Extrahieren der Zahlenwerte
      // Gruppe 1: high, 2: low, 3: f, 4: m, 5: r
      final regExp = RegExp(r"([\d.]+),([\d.]+)\s+f:\s+([\d.]+),\s+m:\s+([\d.]+),\s+r:\s+([\d.]+)");
      final match = regExp.firstMatch(message);

      if (match != null) {
        return Signal(
          high: double.tryParse(match.group(1) ?? '0') ?? 0.0,
          low: double.tryParse(match.group(2) ?? '0') ?? 0.0,
          frequenz: double.tryParse(match.group(3) ?? '0') ?? 0.0,
          modulation: int.tryParse(match.group(4) ?? '0') ?? 0,
          rxBw: double.tryParse(match.group(5) ?? '0') ?? 0.0,
        );
      }
    } catch (e) {
      print("Error parsing Signal string: $e");
    }
    
    // Fallback falls Parsing fehlschlägt
    return Signal(high: 0, low: 0, frequenz: 0, modulation: 0, rxBw: 0);
  }

  // Hilfsmethode zur Erstellung aus einer Map
  factory Signal.fromMap(Map<String, dynamic> map) {
    return Signal(
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      frequenz: (map['frequenz'] as num).toDouble(),
      modulation: map['modulation'] as int,
      rxBw: (map['rxBw'] as num).toDouble(),
    );
  }

  // Methode zur Umwandlung in eine Map
  Map<String, dynamic> toMap() {
    return {
      'high': high,
      'low': low,
      'frequenz': frequenz,
      'modulation': modulation,
      'rxBw': rxBw,
    };
  }
}
