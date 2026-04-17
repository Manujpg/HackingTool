import 'package:flutter/foundation.dart';
import '../model/signal.dart';

class SignalRepository {
  // Privater Konstruktor für Singleton
  SignalRepository._();
  static final SignalRepository instance = SignalRepository._();

  // Die Liste der Signale ist privat, sodass man nicht direkt von außen darauf zugreifen kann
  final List<Signal> _signals = [];

  // Ein ValueNotifier, um UI-Komponenten über Änderungen zu informieren, ohne direkten Listen-Zugriff zu geben
  final ValueNotifier<int> signalCount = ValueNotifier<int>(0);

  /// Fügt ein neues Signal hinzu.
  void addSignal(Signal signal) {
    _signals.add(signal);
    signalCount.value = _signals.length;
    if (kDebugMode) {
      print("SignalRepository: Signal hinzugefügt. Gesamt: ${_signals.length}");
    }
  }

  /// Gibt eine Kopie der Liste zurück, um die interne Liste zu schützen.
  List<Signal> getAllSignals() {
    return List.unmodifiable(_signals);
  }

  /// Leert den Speicher.
  void clear() {
    _signals.clear();
    signalCount.value = 0;
  }
}
