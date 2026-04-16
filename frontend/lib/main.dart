import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'screens/scan_screen.dart';
import 'screens/library_screen.dart';
import 'screens/attack_screen.dart';
import 'screens/device_screen.dart';
import 'widgets/tactical_hover.dart';

void main() {
  runApp(const RFScannerApp());
}

// --- DATENMODELL ---
class SignalItem {
  String name;
  final String hexData;
  final String frequency;
  final DateTime timestamp;

  SignalItem({
    required this.name,
    required this.hexData,
    required this.frequency,
    required this.timestamp,
  });
}

class RFScannerApp extends StatelessWidget {
  const RFScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'ELECTRONIC WARFARE',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF131313),
          primaryColor: const Color(0xFF00FF41),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00FF41),
            surface: Color(0xFF1C1B1B),
            onSurface: Color(0xFFE5E2E1),
            secondary: Color(0xFF00E3FD),
            error: Color(0xFFC40015),
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<SignalItem> _savedSignals = [];

  // NEU: Hält das Signal, das gerade für den Replay ausgewählt wurde
  SignalItem? _activeReplaySignal;

  void _saveSignal(String hex, String freq) {
    setState(() {
      _savedSignals.add(SignalItem(
        name: "SIG_${_savedSignals.length.toString().padLeft(3, '0')}",
        hexData: hex,
        frequency: freq,
        timestamp: DateTime.now(),
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SIGNAL_RECORDED_TO_LIBRARY', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFF00FF41),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _renameSignal(int index, String newName) {
    setState(() => _savedSignals[index].name = newName);
  }

  void _deleteSignal(int index) {
    setState(() => _savedSignals.removeAt(index));
  }

  // --- NEUE NAVIGATIONSLOGIK ---
  void _goToLibrary() {
    setState(() => _selectedIndex = 2);
  }

  void _triggerReplay(int index) {
    setState(() {
      _activeReplaySignal = _savedSignals[index];
      _selectedIndex = 1; // Springt direkt zum Attack Tab
    });
  }

  void _clearReplay() {
    setState(() => _activeReplaySignal = null);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ScanScreen(onSave: _saveSignal),
      AttackScreen(
        activeSignal: _activeReplaySignal,
        onGoToLibrary: _goToLibrary,
        onClearSignal: _clearReplay,
      ),
      LibraryScreen(
        signals: _savedSignals,
        onRename: _renameSignal,
        onDelete: _deleteSignal,
        onReplay: _triggerReplay, // Neue Funktion für die Library
      ),
      const DeviceScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313).withOpacity(0.8),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.terminal, color: Color(0xFF00FF41), size: 20),
            const SizedBox(width: 8),
            Text('ELECTRONIC WARFARE v1.0', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF00FF41), shadows: [const Shadow(color: Color(0xFF00FF41), blurRadius: 8)])),
          ],
        ),
        actions: const [
          Icon(Icons.sensors, color: Color(0xFF00FF41), size: 20), SizedBox(width: 12),
          Icon(Icons.battery_full, color: Color(0xFF00FF41), size: 16), SizedBox(width: 4),
          Icon(Icons.signal_cellular_alt, color: Color(0xFF00FF41), size: 16), SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            height: 40, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF1C1B1B).withOpacity(0.5)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00FF41), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0xFF00FF41), blurRadius: 4)])),
                  const SizedBox(width: 8),
                  Text('STATUS: CONNECTED (ESP32)', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: screens),
          IgnorePointer(child: CustomPaint(size: Size.infinite, painter: ScanlinePainter())),
          IgnorePointer(child: Container(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.2, colors: [Colors.transparent, Colors.black.withOpacity(0.3)])))),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70, decoration: const BoxDecoration(color: Color(0xFF0E0E0E), border: Border(top: BorderSide(color: Colors.white10, width: 1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.radar, "SCANNER"),
            _navItem(1, Icons.bolt, "ATTACK"),
            _navItem(2, Icons.folder_special, "LIBRARY"),
            _navItem(3, Icons.settings_input_component, "SYSTEM"),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool active = _selectedIndex == index;
    return TacticalHover(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 80,
        decoration: active ? BoxDecoration(color: const Color(0xFF00FF41).withOpacity(0.1), border: const Border(top: BorderSide(color: Color(0xFF00FF41), width: 2))) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? const Color(0xFF00FF41) : const Color(0xFF84967E), size: 24, shadows: active ? [const Shadow(color: Color(0xFF00FF41), blurRadius: 10)] : null),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.spaceGrotesk(color: active ? const Color(0xFF00FF41) : const Color(0xFF84967E), fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.1)..strokeWidth = 1.0;
    for (double i = 0; i < size.height; i += 4.0) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}