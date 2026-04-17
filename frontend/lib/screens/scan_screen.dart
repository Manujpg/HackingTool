import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../widgets/tactical_hover.dart';

class ScanScreen extends StatefulWidget {
  final Function(String hex, String freq) onSave;
  const ScanScreen({super.key, required this.onSave});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  late AnimationController _scopeController;
  late TextEditingController _freqController;
  double _currentFreq = 433.92;

  // --- NEU: Erweiterte Radio Settings mit Details ---
  int _modIndex = 0;
  final List<Map<String, String>> _modulationsData = [
    {
      "name": "2-FSK",
      "desc": "Binary Frequency Shift Keying. Wechselt zwischen zwei Frequenzen.\nEinsatz: Standard-Datenübertragung (Sensoren)"
    },
    {
      "name": "GFSK",
      "desc": "Gaussian Frequency Shift Keying. Wie FSK, aber mit sanfteren Übergängen.\nEinsatz: Effizientere Bandbreitennutzung"
    },
    {
      "name": "ASK / OOK",
      "desc": "Amplitude Shift Keying / On-Off Keying. Welle an (1) oder aus (0).\nEinsatz: Garagentore, Funksteckdosen"
    },
    {
      "name": "4-FSK",
      "desc": "Wechselt zwischen vier verschiedenen Frequenzen.\nEinsatz: Höhere Datenraten"
    },
    {
      "name": "MSK",
      "desc": "Minimum Shift Keying. Eine Form von FSK mit minimalem Frequenzabstand.\nEinsatz: Spezialanwendungen"
    },
  ];
  bool _rxBwHigh = true;

  // --- Radar State ---
  bool _isRadarMode = false;
  bool _isRadarSweeping = false;
  late AnimationController _radarController;

  late TextEditingController _minFreqCtrl;
  late TextEditingController _maxFreqCtrl;
  late TextEditingController _stepCtrl;

  @override
  void initState() {
    super.initState();
    _scopeController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _freqController = TextEditingController(text: _currentFreq.toStringAsFixed(2));

    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _minFreqCtrl = TextEditingController(text: "420.0");
    _maxFreqCtrl = TextEditingController(text: "430.0");
    _stepCtrl = TextEditingController(text: "1.0");
  }

  @override
  void dispose() {
    _scopeController.dispose();
    _freqController.dispose();
    _radarController.dispose();
    _minFreqCtrl.dispose();
    _maxFreqCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  void _updateFrequency(double newFreq) {
    double cappedFreq = newFreq > 999.99 ? 999.99 : (newFreq < 0.0 ? 0.0 : newFreq);
    setState(() {
      _currentFreq = cappedFreq;
      _freqController.text = _currentFreq.toStringAsFixed(2);
    });
  }

  void _toggleRadarMode() {
    setState(() {
      _isRadarMode = !_isRadarMode;
      if (!_isRadarMode) {
        _isRadarSweeping = false;
        _radarController.stop();
      }
    });
  }

  void _toggleRadarSweep() {
    setState(() {
      _isRadarSweeping = !_isRadarSweeping;
      if (_isRadarSweeping) {
        _radarController.repeat();
      } else {
        _radarController.stop();
      }
    });
  }

  // --- NEU: Brutalistisches Info-Popup ---
  void _showInfoDialog(String title, String text) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(2),
            color: const Color(0xFF00E3FD), // Signalblau für Info
            child: Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0D0D0D),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF00E3FD), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(title, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(text, style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 11, height: 1.4)),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("ACKNOWLEDGE", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontWeight: FontWeight.bold, letterSpacing: 1))
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRadarMode) {
      return _buildRadarScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFrequencyInputBox(),
          const SizedBox(height: 16),
          _buildPresetRow(),
          const SizedBox(height: 16),
          _buildScopeArea(),
          const SizedBox(height: 16),
          _buildRadioSettingsRow(),
          const SizedBox(height: 16),
          _buildSnifferLog(),
          const SizedBox(height: 24),
          TacticalHover(
            onTap: _toggleRadarMode,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF00E3FD).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF00E3FD)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.radar, color: Color(0xFF00E3FD)),
                  const SizedBox(width: 12),
                  Text("ENTER RANGE RADAR MODE", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ANGEPASSTE RADIO SETTINGS MIT INFO-ICONS ---
  Widget _buildRadioSettingsRow() {
    return Row(
      children: [
        // MODULATION PANEL
        Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1C1B1B), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("MODULATION", style: GoogleFonts.spaceGrotesk(fontSize: 8, color: const Color(0xFF84967E))),
                      GestureDetector(
                        onTap: () => _showInfoDialog(
                            "MODULATION PROTOCOL",
                            "Aktuell ausgewählt:\n[${_modulationsData[_modIndex]['name']}]\n\n${_modulationsData[_modIndex]['desc']}\n\nAllgemein:\nModulation beschreibt die Methode, mit der digitale Datenpakete in analoge Funkwellen umgewandelt werden."
                        ),
                        child: const Icon(Icons.info_outline, size: 14, color: Color(0xFF84967E)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Clickable Area für Modulation Change
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _modIndex = (_modIndex + 1) % _modulationsData.length),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_modulationsData[_modIndex]['name']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: const Color(0xFF00FF41), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(_modulationsData.length, (i) => Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: i < (_modulationsData.length - 1) ? 2 : 0),
                                height: 2,
                                color: i <= _modIndex ? const Color(0xFF00FF41) : Colors.white10,
                              )
                          )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        ),
        const SizedBox(width: 12),
        // RXBW PANEL
        Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1C1B1B), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("RxBW", style: GoogleFonts.spaceGrotesk(fontSize: 8, color: const Color(0xFF84967E))),
                      GestureDetector(
                        onTap: () => _showInfoDialog(
                            "RECEIVER BANDWIDTH (RxBW)",
                            "Die Bandbreite des Empfangsfilters am CC1101.\n\nHIGH:\nErfasst mehr Signale in der Umgebung, ist aber deutlich anfälliger für Hintergrundrauschen.\n\nLOW:\nPräziserer Empfang, filtert Rauschen besser heraus, kann aber Signale verfehlen, wenn diese eine leichte Frequenzabweichung aufweisen."
                        ),
                        child: const Icon(Icons.info_outline, size: 14, color: Color(0xFF84967E)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Clickable Area für RxBW Change
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _rxBwHigh = !_rxBwHigh),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_rxBwHigh ? "HIGH" : "LOW", style: GoogleFonts.spaceGrotesk(fontSize: 12, color: _rxBwHigh ? const Color(0xFF00E3FD) : const Color(0xFFFFB4AB), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(height: 2, color: _rxBwHigh ? const Color(0xFF00E3FD) : const Color(0xFFFFB4AB)),
                      ],
                    ),
                  )
                ],
              ),
            )
        ),
      ],
    );
  }

  // --- RADAR FULLSCREEN MODUS ---
  Widget _buildRadarScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 10),
          child: GestureDetector(
            onTap: _toggleRadarMode,
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text("ABORT RADAR & RETURN", style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1C1B1B), border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SWEEP PARAMETERS", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _radarInputBox("MIN (MHz)", _minFreqCtrl)),
                        const SizedBox(width: 8),
                        Expanded(child: _radarInputBox("MAX (MHz)", _maxFreqCtrl)),
                        const SizedBox(width: 8),
                        Expanded(child: _radarInputBox("STEP (MHz)", _stepCtrl)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.2)),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 1, height: double.infinity, color: const Color(0xFF00E3FD).withOpacity(0.2)),
                    Container(width: double.infinity, height: 1, color: const Color(0xFF00E3FD).withOpacity(0.2)),
                    Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.1)))),
                    Container(width: 75, height: 75, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.1)))),

                    AnimatedBuilder(
                      animation: _radarController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _radarController.value * 2 * math.pi,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [Colors.transparent, const Color(0xFF00E3FD).withOpacity(0.8)],
                                stops: const [0.75, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    AnimatedBuilder(
                        animation: _radarController,
                        builder: (context, child) {
                          double min = double.tryParse(_minFreqCtrl.text) ?? 420.0;
                          double max = double.tryParse(_maxFreqCtrl.text) ?? 430.0;
                          double current = min + ((max - min) * _radarController.value);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.black87,
                            child: Text(
                              _isRadarSweeping ? "${current.toStringAsFixed(2)} MHz" : "IDLE",
                              style: GoogleFonts.spaceGrotesk(color: _isRadarSweeping ? const Color(0xFF00E3FD) : Colors.white54, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TacticalHover(
                onTap: _toggleRadarSweep,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isRadarSweeping ? const Color(0xFF00E3FD).withOpacity(0.2) : const Color(0xFF1C1B1B),
                    border: Border.all(color: const Color(0xFF00E3FD), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _isRadarSweeping ? "HALT SWEEP" : "INITIATE RADAR SWEEP",
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00E3FD), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(color: const Color(0xFF222222), border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.3))),
                child: Column(
                  children: [
                    Container(padding: const EdgeInsets.all(8), color: const Color(0xFF00E3FD).withOpacity(0.1), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("INTERCEPTED SIGNALS", style: GoogleFonts.spaceGrotesk(fontSize: 10, color: const Color(0xFF00E3FD), fontWeight: FontWeight.bold)), Text("FOUND: 3", style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.white))])),
                    ListView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 3,
                      itemBuilder: (context, index) {
                        List<String> mockFreqs = ["422.15 MHz", "426.00 MHz", "428.85 MHz"];
                        return ListTile(
                          dense: true,
                          title: Text("0xRADAR_SIG_$index", style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                          subtitle: Text(mockFreqs[index], style: const TextStyle(color: Color(0xFF00E3FD), fontSize: 9)),
                          trailing: GestureDetector(
                            onTap: () => widget.onSave("0xRADAR_SIG_$index", mockFreqs[index]),
                            child: const Icon(Icons.save_alt, color: Color(0xFF00E3FD), size: 16),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _radarInputBox(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E), fontSize: 8)),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF252525), Color(0xFF1A1A1A)]),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _freqController,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 54, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none),
            onSubmitted: (v) => _updateFrequency(double.tryParse(v.replaceAll(',', '.')) ?? _currentFreq),
          ),
          const SizedBox(height: 4),
          Text("M H z", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), letterSpacing: 8, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPresetRow() {
    return Wrap(
      spacing: 10,
      children: ["315.00 MHz", "433.92 MHz", "868.00 MHz", "915.00 MHz"].map((label) =>
          GestureDetector(
            onTap: () => _updateFrequency(double.parse(label.split(' ')[0])),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _currentFreq == double.parse(label.split(' ')[0]) ? const Color(0xFF00FF41).withOpacity(0.2) : const Color(0xFF222222),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: const Color(0xFF84967E))),
            ),
          )
      ).toList(),
    );
  }

  Widget _buildScopeArea() {
    return Container(
      height: 180,
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), border: Border.all(color: Colors.white10)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _scopeController,
              builder: (context, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (i) => Container(
                  width: 4, height: 15 + math.Random().nextDouble() * 100,
                  color: const Color(0xFF00FF41).withOpacity(0.3),
                )),
              ),
            ),
          ),
          const Positioned(top: 10, left: 10, child: Text("LIVE_SCOPE_READY", style: TextStyle(color: Color(0xFF00FF41), fontSize: 9))),
        ],
      ),
    );
  }

  Widget _buildSnifferLog() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF222222), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8), color: const Color(0xFF2A2A2A), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("SNIFFER LOG", style: GoogleFonts.spaceGrotesk(fontSize: 10)), Text("PACKETS: 1,482", style: GoogleFonts.spaceGrotesk(fontSize: 8, color: const Color(0xFF00FF41)))])),
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 4,
            itemBuilder: (context, index) => ListTile(
              dense: true,
              title: Text("0xAF4B901C7$index", style: const TextStyle(color: Color(0xFF00FF41), fontSize: 10, fontFamily: 'monospace')),
              trailing: GestureDetector(
                onTap: () => widget.onSave("0xAF4B901C7$index", "${_currentFreq.toStringAsFixed(2)} MHz"),
                child: const Icon(Icons.save_alt, color: Color(0xFF84967E), size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}