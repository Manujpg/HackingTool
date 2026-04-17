import 'package:flutter/foundation.dart';
import 'ble_service.dart';

class RadioService {
  // Singleton Pattern
  RadioService._();
  static final RadioService instance = RadioService._();

  final BleService _ble = BleService.instance;

  // Zentraler Status
  final ValueNotifier<double> frequency = ValueNotifier(433.92);
  final ValueNotifier<int> modulation = ValueNotifier(0);
  final ValueNotifier<double> rxBandwidth = ValueNotifier(812.5);

  /// Setzt die Frequenz am CC1101 (setFrequenz=xxx.xx)
  Future<void> setFrequency(double freq, {bool force = false}) async {
    if (!force && frequency.value == freq) return;
    frequency.value = freq;
    await _ble.sendVariable("setFrequenz", freq);
  }

  /// Setzt die Modulation (setModulation=x)
  Future<void> setModulation(int modIndex, {bool force = false}) async {
    if (!force && modulation.value == modIndex) return;
    modulation.value = modIndex;
    await _ble.sendVariable("setModulation", modIndex);
  }

  /// Setzt die RX Bandbreite (setRxBw=xxx.xx)
  Future<void> setRxBandwidth(double bw, {bool force = false}) async {
    if (!force && rxBandwidth.value == bw) return;
    rxBandwidth.value = bw;
    await _ble.sendVariable("setRxBw", bw);
  }

  /// Sendet Text an den ESP32 zur Anzeige (displayText=text)
  Future<void> displayText(String text) async {
    await _ble.sendCommand("displayText=$text");
  }

  /// Startet das Jamming (startJamming)
  Future<void> startJamming() async {
    await _ble.sendCommand("startJamming");
  }

  /// Stoppt das Jamming (stopJamming)
  Future<void> stopJamming() async {
    await _ble.sendCommand("stopJamming");
  }

  /// Startet einen Frequenz-Scan (Radar) über einen Bereich
  /// Format: startScanningFrequenz(start,end,step)
  Future<void> startFrequencyScanning(double pStartFreq, double pEndFreq, double pScanStep) async {
    final cmd = "startScanningFrequenz(${pStartFreq.toStringAsFixed(2)},${pEndFreq.toStringAsFixed(2)},${pScanStep.toStringAsFixed(2)})";
    await _ble.sendCommand(cmd);
  }

  /// Stoppt den Frequenz-Scan (stopScanningFrequenz)
  Future<void> stopFrequencyScanning() async {
    await _ble.sendCommand("stopScanningFrequenz");
  }

  /// Sendet ein spezifisches Signal (RAW Code)
  /// Format: startSendData[code1,code2,...]
  Future<void> sendSignal(List<int> codes) async {
    final codesStr = codes.join(",");
    await _ble.sendCommand("startSendData[$codesStr]");
  }

  // --- Getter Befehle (Abfrage vom ESP32) ---

  Future<void> requestMode() async {
    await _ble.sendCommand("getMode");
  }

  Future<void> requestFrequency() async {
    await _ble.sendCommand("getFrequenz");
  }

  Future<void> requestModulation() async {
    await _ble.sendCommand("getModulation");
  }

  Future<void> requestRxBandwidth() async {
    await _ble.sendCommand("getRxBw");
  }
}
