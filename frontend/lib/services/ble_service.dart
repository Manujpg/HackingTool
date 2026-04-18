import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  BleService._();
  static final BleService instance = BleService._();

  static const String _targetDeviceName = 'ESP32_BLE_Device';
  static final Guid _serviceUuid = Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b');
  static final Guid _rxUuid = Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8');
  static final Guid _txUuid = Guid('e3223119-9445-4e96-a4a1-85358c4046a2');

  final ValueNotifier<String> status = ValueNotifier<String>('DISCONNECTED');
  final ValueNotifier<List<String>> messages = ValueNotifier<List<String>>(<String>[]);
  final ValueNotifier<List<String>> discoveredDevices = ValueNotifier<List<String>>(<String>[]);
  final ValueNotifier<String> scanDebug = ValueNotifier<String>('');

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxCharacteristic;
  final Map<String, BluetoothDevice> _scanDeviceMap = <String, BluetoothDevice>{};

  bool _isStarting = false;
  bool _foundDuringScan = false;

  Future<void> start({bool forceRestart = false}) async {
    if (_isStarting) return;
    _isStarting = true;
    try {
      final permissionOk = await _ensurePermissions();
      if (!permissionOk) {
        return;
      }

      if (forceRestart) {
        await _stopScan();
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        status.value = 'BLUETOOTH_OFF';
        return;
      }

      status.value = 'SCANNING';
      scanDebug.value = 'scan-start';
      _foundDuringScan = false;
      _scanDeviceMap.clear();
      discoveredDevices.value = <String>[];

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
        scanDebug.value = 'scan-callback: ${results.length} result(s)';
        final labels = <String>[];
        for (final result in results) {
          _scanDeviceMap[result.device.remoteId.str] = result.device;
          final deviceName = result.device.platformName.trim();
          final advName = result.advertisementData.advName.trim();
          final shownName = deviceName.isNotEmpty
              ? deviceName
              : (advName.isNotEmpty ? advName : 'Unknown');
          labels.add('$shownName | ${result.device.remoteId.str} | RSSI ${result.rssi}');
        }
        discoveredDevices.value = labels;

        for (final result in results) {
          if (_matchesTargetResult(result)) {
            _foundDuringScan = true;
            await FlutterBluePlus.stopScan();
            _scanSubscription?.cancel();
            await _connect(result.device);
            break;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        androidScanMode: AndroidScanMode.lowLatency,
        androidCheckLocationServices: false,
        androidUsesFineLocation: true,
        continuousUpdates: true,
        removeIfGone: const Duration(seconds: 4),
      );

      Future<void>.delayed(const Duration(seconds: 11), () {
        if (!_foundDuringScan && status.value == 'SCANNING') {
          status.value = 'NOT_FOUND';
          scanDebug.value = 'scan-timeout-no-match';
        }
      });
    } catch (e) {
      status.value = 'SCAN_FAILED';
      scanDebug.value = 'scan-error: $e';
    } finally {
      _isStarting = false;
    }
  }

  Future<void> retry() async {
    await start(forceRestart: true);
  }

  Future<void> connectByDeviceId(String deviceId) async {
    final device = _scanDeviceMap[deviceId];
    if (device == null) {
      status.value = 'DEVICE_NOT_IN_SCAN';
      return;
    }

    await _stopScan();
    await _connect(device);
  }

  Future<bool> _ensurePermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    final bluetoothOk = scanStatus.isGranted && connectStatus.isGranted;
    final locationOk = locationStatus.isGranted || locationStatus.isLimited;
    if (bluetoothOk && locationOk) {
      return true;
    }

    final permanentlyDenied =
      scanStatus.isPermanentlyDenied || connectStatus.isPermanentlyDenied || locationStatus.isPermanentlyDenied;

    if (permanentlyDenied) {
      status.value = 'PERMISSION_PERMANENTLY_DENIED';
      await openAppSettings();
      return false;
    }

    status.value = 'PERMISSION_DENIED';
    scanDebug.value = 'perm scan=$scanStatus connect=$connectStatus location=$locationStatus';
    return false;
  }

  Future<void> _stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await FlutterBluePlus.stopScan();
  }

  bool _matchesTargetResult(ScanResult result) {
    if (_matchesTargetName(result.device.platformName)) {
      return true;
    }

    if (_matchesTargetName(result.advertisementData.advName)) {
      return true;
    }

    final expectedService = _serviceUuid.toString().toLowerCase();
    for (final serviceUuid in result.advertisementData.serviceUuids) {
      if (serviceUuid.toString().toLowerCase() == expectedService) {
        return true;
      }
    }

    return false;
  }

  bool _matchesTargetName(String name) {
    return name.trim() == _targetDeviceName;
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      status.value = 'CONNECTING';
      _device = device;

      await device.connect(timeout: const Duration(seconds: 10));
      
      try {
        // Kleiner Delay, da Android manchmal abstürzt, wenn MTU sofort nach Connect angefragt wird
        await Future.delayed(const Duration(milliseconds: 500));
        await device.requestMtu(185);
      } catch (e) {
        if (kDebugMode) print('MTU Request ignoriert: $e');
      }

      final services = await device.discoverServices();
      if (kDebugMode) {
        for (var s in services) {
          print("Service found: ${s.uuid}");
          for (var c in s.characteristics) {
            print("  Char found: ${c.uuid} | Write: ${c.properties.write} | Notify: ${c.properties.notify}");
          }
        }
      }

      final service = services.where((s) => s.uuid == _serviceUuid).firstOrNull;
      if (service == null) {
        if (kDebugMode) print("ERROR: Service $_serviceUuid not found!");
        status.value = 'SERVICE_NOT_FOUND';
        return;
      }

      _rxCharacteristic = service.characteristics.where((c) => c.uuid == _rxUuid).firstOrNull;
      final txCharacteristic = service.characteristics.where((c) => c.uuid == _txUuid).firstOrNull;

      if (_rxCharacteristic == null && kDebugMode) print("ERROR: RX Characteristic $_rxUuid not found!");
      if (txCharacteristic == null && kDebugMode) print("ERROR: TX Characteristic $_txUuid not found!");

      if (txCharacteristic == null) {
        status.value = 'TX_CHAR_NOT_FOUND';
        return;
      }

      if (txCharacteristic.properties.notify) {
        await txCharacteristic.setNotifyValue(true);
      }

      // Bug-Fix: Erneuter Fehlervermeidung bei extrem schnellen Bluetooth-Feuer
      _notifySubscription?.cancel();
      _notifySubscription = txCharacteristic.onValueReceived.listen((data) {
        try {
          final text = utf8.decode(data, allowMalformed: true).trim();
          if (text.isEmpty) return;

          // Hässlichen RangeError komplett umgehen!
          final newList = <String>[text, ...messages.value];
          if (newList.length > 50) {
            messages.value = newList.sublist(0, 50);
          } else {
            messages.value = newList;
          }
        } catch (e) {
          if (kDebugMode) print('Error parsing BLE message: $e');
        }
      });

      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          status.value = 'DISCONNECTED';
          _rxCharacteristic = null;
        }
      });

      status.value = 'CONNECTED';
      await sendCommand('ping_from_flutter');
    } catch (e) {
      status.value = 'CONNECT_FAILED';
      scanDebug.value = 'Connect-Error: $e';
      if (kDebugMode) {
        print('Ble connect error: $e');
      }
    }
  }

  Future<void> sendCommand(String command) async {
    final characteristic = _rxCharacteristic;
    if (characteristic == null) return;

    final payload = utf8.encode(command);
    await characteristic.write(payload, withoutResponse: true);
  }

  // NEU: Hilfs-Funktion um Variablen einfach an den ESP32 zu senden
  // Unterstützt String, int, double (float) und bool.
  Future<void> sendVariable(String key, dynamic value) async {
    String valueStr = value.toString();
    if (value is bool) {
      valueStr = value ? "1" : "0";
    }
    await sendCommand('$key=$valueStr');
  }

  Future<void> dispose() async {
    await _notifySubscription?.cancel();
    await _stopScan();
    discoveredDevices.value = <String>[];
    scanDebug.value = '';
    _scanDeviceMap.clear();
    final device = _device;
    _device = null;
    if (device != null) {
      await device.disconnect();
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
