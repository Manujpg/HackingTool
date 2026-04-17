import 'package:flutter/foundation.dart';
import '../model/scan_freq.dart';

class ScanFreqRepository {
  ScanFreqRepository._();
  static final ScanFreqRepository instance = ScanFreqRepository._();

  final List<ScanFreq> _hits = [];
  final ValueNotifier<int> hitCount = ValueNotifier<int>(0);

  void addHit(ScanFreq hit) {
    _hits.add(hit);
    hitCount.value = _hits.length;
  }

  List<ScanFreq> getAllHits() {
    return List.unmodifiable(_hits);
  }

  void clear() {
    _hits.clear();
    hitCount.value = 0;
  }
}
