import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/tactical_hover.dart';
import '../main.dart'; // Für das SignalItem
import '../services/db.dart';

enum AttackMode { selection, jamming, replay }

class AttackScreen extends StatefulWidget {
  final SignalItem? activeSignal;
  final VoidCallback onGoToLibrary;
  final VoidCallback onClearSignal;

  const AttackScreen({
    super.key,
    required this.activeSignal,
    required this.onGoToLibrary,
    required this.onClearSignal,
  });

  @override
  State<AttackScreen> createState() => _AttackScreenState();
}

class _AttackScreenState extends State<AttackScreen> {
  AttackMode _mode = AttackMode.selection;

  // Jamming State
  bool _isJamming = false;
  double _currentJamFreq = 433.92;
  late TextEditingController _jamFreqController;

  // Replay State
  bool _isReplaying = false;

  @override
  void initState() {
    super.initState();
    _jamFreqController = TextEditingController(text: _currentJamFreq.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _jamFreqController.dispose();
    super.dispose();
  }

  void _updateJamFrequency(double newFreq) {
    double cappedFreq = newFreq > 999.99 ? 999.99 : (newFreq < 0.0 ? 0.0 : newFreq);
    setState(() {
      _currentJamFreq = cappedFreq;
      _jamFreqController.text = _currentJamFreq.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    AttackMode currentMode = widget.activeSignal != null ? AttackMode.replay : _mode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentMode != AttackMode.selection)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 20),
            child: GestureDetector(
              onTap: () {
                widget.onClearSignal();
                setState(() => _mode = AttackMode.selection);
              },
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                  const SizedBox(width: 8),
                  Text("ABORT & RETURN", style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

        Expanded(
          child: _buildCurrentView(currentMode),
        ),
      ],
    );
  }

  Widget _buildCurrentView(AttackMode mode) {
    switch (mode) {
      case AttackMode.selection:
        return _buildSelectionMode();
      case AttackMode.jamming:
        return _buildJammingMode();
      case AttackMode.replay:
        return _buildReplayMode();
    }
  }

  // --- 1. SELECTION MODE (BRUTALIST MONOLITH LOOK) ---
  Widget _buildSelectionMode() {
    return Column(
      children: [
        // LEISTE OBEN
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFF131313)),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Text(
                "SELECT COMBAT VECTOR",
                style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF00FF41),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(color: const Color(0xFF00FF41).withOpacity(0.15)),
              ),
            ],
          ),
        ),
        // DIE BEIDEN MONOLITH-BLÖCKE
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // REPLAY FELD (Links, Blau)
              Expanded(
                child: TacticalHover(
                  onTap: () => setState(() => _mode = AttackMode.replay),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFF00E3FD).withOpacity(0.08),
                        border: Border(
                          right: BorderSide(color: const Color(0xFF00E3FD).withOpacity(0.2), width: 1),
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.repeat, color: Color(0xFF00E3FD), size: 56),
                        const SizedBox(height: 20),
                        Text("REPLAY", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
              ),
              // JAMMING FELD (Rechts, Rot)
              Expanded(
                child: TacticalHover(
                  onTap: () => setState(() => _mode = AttackMode.jamming),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFFC40015).withOpacity(0.08)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, color: Color(0xFFC40015), size: 56),
                        const SizedBox(height: 20),
                        Text("JAMMING", style: GoogleFonts.spaceGrotesk(color: const Color(0xFFC40015), fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // FÜLLER UNTEN
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xFF131313),
              border: Border(top: BorderSide(color: const Color(0xFF00FF41).withOpacity(0.1), width: 1))),
        ),
      ],
    );
  }

  // --- 2. JAMMING MODE (ROT) ---
  Widget _buildJammingMode() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF250000), Color(0xFF1A0000)]),
            border: Border.all(color: const Color(0xFFC40015).withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 10),
              BoxShadow(color: const Color(0xFFC40015).withOpacity(0.1), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _jamFreqController,
                readOnly: _isJamming, // <--- HIER: Blockiert die Eingabe während Jamming läuft
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(color: const Color(0xFFC40015), fontSize: 54, fontWeight: FontWeight.bold, letterSpacing: -1, shadows: [Shadow(color: const Color(0xFFC40015).withOpacity(0.6), blurRadius: 12)]),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                onSubmitted: (v) => _updateJamFrequency(double.tryParse(v.replaceAll(',', '.')) ?? _currentJamFreq),
              ),
              const SizedBox(height: 8),
              Text("TARGET MHz", style: GoogleFonts.spaceGrotesk(color: const Color(0xFFC40015).withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4)),
            ],
          ),
        ),

        const SizedBox(height: 40),
        TacticalHover(
          onTap: () => setState(() => _isJamming = !_isJamming),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: _isJamming ? const Color(0xFFC40015) : const Color(0xFFC40015).withOpacity(0.1),
              border: Border.all(color: const Color(0xFFC40015), width: 2),
            ),
            child: Center(
              child: Text(
                _isJamming ? 'CEASE FLOODING' : 'ENGAGE JAMMER',
                style: GoogleFonts.spaceGrotesk(color: _isJamming ? Colors.black : const Color(0xFFC40015), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. REPLAY MODE (BLAU) ---
  Widget _buildReplayMode() {
    if (widget.activeSignal == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white24, size: 48),
            const SizedBox(height: 20),
            Text("NO REPLAY VECTOR SELECTED", style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: widget.onGoToLibrary,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00E3FD))),
                child: Text("OPEN LIBRARY", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            )
          ],
        ),
      );
    }

    // Wenn ein Signal geladen wurde:
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1C1B1B), border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.3), width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ARMED_SIGNAL", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 10),
              Text(widget.activeSignal!.name, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _replayDataRow("FREQUENCY", widget.activeSignal!.frequency),
              const SizedBox(height: 10),
              _replayDataRow("PAYLOAD", widget.activeSignal!.hexData),
            ],
          ),
        ),
        const SizedBox(height: 40),
        TacticalHover(
          onTap: () {
            setState(() => _isReplaying = true);
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) setState(() => _isReplaying = false);
            });
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: _isReplaying ? const Color(0xFF00E3FD) : const Color(0xFF00E3FD).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF00E3FD), width: 2),
            ),
            child: Center(
              child: Text(
                _isReplaying ? 'TRANSMITTING...' : 'SEND REPLAY',
                style: GoogleFonts.spaceGrotesk(color: _isReplaying ? Colors.black : const Color(0xFF00E3FD), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _replayDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 10)),
        Text(value, style: const TextStyle(color: Color(0xFF00E3FD), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}