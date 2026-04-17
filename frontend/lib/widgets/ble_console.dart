import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ble_service.dart';
import '../services/ble_message_handler.dart';
import 'tactical_hover.dart';

class BleConsole extends StatefulWidget {
  const BleConsole({super.key});

  @override
  State<BleConsole> createState() => _BleConsoleState();
}

class _BleConsoleState extends State<BleConsole> {
  final BleService _bleService = BleService.instance;
  final TextEditingController _testSendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listener hinzufügen, um auf neue Nachrichten zu reagieren und Toasts anzuzeigen
    _bleService.messages.addListener(_onMessagesChanged);
  }

  @override
  void dispose() {
    _bleService.messages.removeListener(_onMessagesChanged);
    _testSendController.dispose();
    super.dispose();
  }

  void _onMessagesChanged() {
    if (_bleService.messages.value.isNotEmpty) {
      // Die neueste Nachricht ist immer an Index 0 (siehe BleService._connect)
      final latestMessage = _bleService.messages.value.first;
      BleMessageHandler.handleMessage(context, latestMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: const Color(0xFF00E3FD).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bluetooth_connected, color: Color(0xFF00E3FD), size: 16),
              const SizedBox(width: 8),
              Text(
                'BLE_CONSOLE',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF00E3FD),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: _bleService.status,
            builder: (context, status, _) {
              return Text(
                'STATUS: $status',
                style: GoogleFonts.spaceGrotesk(
                  color: status == 'CONNECTED' ? const Color(0xFF00FF41) : const Color(0xFF84967E),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TacticalHover(
            onTap: _bleService.retry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E3FD).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF00E3FD).withValues(alpha: 0.35)),
              ),
              child: Center(
                child: Text(
                  'RETRY CONNECT',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF00E3FD),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Falls SCANNING bleibt: Bluetooth/Permissions am Handy erlauben und Retry druecken.',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white54,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<String>(
            valueListenable: _bleService.scanDebug,
            builder: (context, debug, _) {
              if (debug.isEmpty) return const SizedBox.shrink();
              return Text(
                'DEBUG: $debug',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white38,
                  fontSize: 8,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Gefundene BLE Geraete (tap = connect):',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF84967E),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(color: Colors.white10),
            ),
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _bleService.discoveredDevices,
              builder: (context, devices, _) {
                if (devices.isEmpty) {
                  return Text(
                    'Noch keine BLE-Geraete im Scan sichtbar.',
                    style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 9),
                  );
                }

                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final row = devices[index];
                    final parts = row.split(' | ');
                    final id = parts.length > 1 ? parts[1] : '';

                    return TacticalHover(
                      onTap: id.isEmpty ? null : () => _bleService.connectByDeviceId(id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          row,
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFF00E3FD),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white10),
            ),
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _bleService.messages,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Text(
                    'Warte auf BLE-Daten vom ESP32...',
                    style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 10),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        items[index],
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF00FF41),
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TacticalHover(
                  onTap: () => _bleService.sendCommand('startJamming'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC40015).withValues(alpha: 0.08),
                      border: Border.all(color: const Color(0xFFC40015).withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        'SEND: startJamming',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFC40015),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TacticalHover(
                  onTap: () => _bleService.sendCommand('stopJamming'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF41).withValues(alpha: 0.08),
                      border: Border.all(color: const Color(0xFF00FF41).withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        'SEND: stopJamming',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF00FF41),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.send_rounded, color: Color(0xFF00E3FD), size: 14),
              const SizedBox(width: 8),
              Text(
                'TEST SENDING DATA',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF00E3FD),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: _testSendController,
                    style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 12),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Befehl (z.B. test=123 oder custom_cmd)',
                      hintStyle: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 10),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _bleService.sendCommand(value);
                        _testSendController.clear();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TacticalHover(
                onTap: () {
                  final text = _testSendController.text.trim();
                  if (text.isNotEmpty) {
                    _bleService.sendCommand(text);
                    _testSendController.clear();
                  }
                },
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E3FD).withValues(alpha: 0.1),
                    border: Border.all(color: const Color(0xFF00E3FD).withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      'SEND',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFF00E3FD),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
