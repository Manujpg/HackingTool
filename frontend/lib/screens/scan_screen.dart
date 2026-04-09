import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../widgets/tactical_hover.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _currentFreq = 433.92;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF131313),
      child: Column(
        children: [
          _buildFrequencySection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildScopeArea(),
                  const SizedBox(height: 16),
                  _buildMetricsRow(),
                  const SizedBox(height: 16),
                  _buildSnifferLog(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border(bottom: BorderSide(color: const Color(0xFF00FF41).withValues(alpha: 0.1), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_antenna, color: Color(0xFF84967E), size: 14),
              const SizedBox(width: 8),
              Text(
                'FREQUENCY CONTROL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: const Color(0xFF84967E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF353534),
                border: Border(top: BorderSide(color: const Color(0xFF00FF41).withValues(alpha: 0.2), width: 2)),
              ),
              child: Column(
                children: [
                  Text(
                    _currentFreq.toStringAsFixed(2),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00FF41),
                      shadows: [const Shadow(color: Color(0xFF00FF41), blurRadius: 10)],
                    ),
                  ),
                  Text(
                    'MHz',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: const Color(0xFF00FF41).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetBtn("315.00 MHz", _currentFreq == 315.00),
              _presetBtn("433.92 MHz", _currentFreq == 433.92),
              _presetBtn("868.00 MHz", _currentFreq == 868.00),
              _presetBtn("915.00 MHz", _currentFreq == 915.00),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetBtn(String label, bool active) {
    return TacticalHover(
      onTap: () {
        setState(() {
          _currentFreq = double.parse(label.split(' ')[0]);
        });
      },
      scale: 1.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00FF41).withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          border: Border.all(
            color: active
                ? const Color(0xFF00FF41).withValues(alpha: 0.4)
                : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            color: active ? const Color(0xFF00FF41) : const Color(0xFF84967E),
          ),
        ),
      ),
    );
  }

  Widget _buildScopeArea() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B).withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          // Grid
          CustomPaint(
            painter: GridPainter(),
            size: Size.infinite,
          ),
          // Status Labels
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF41),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0xFF00FF41), blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE_SCOPE_READY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: const Color(0xFF00FF41),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 28,
            left: 12,
            child: Text(
              'SAMPLING: 2.4 MSPS',
              style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: Colors.white24),
            ),
          ),
          // Waveform
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(24, (index) {
                      double randomHeight = 20 + math.Random().nextDouble() * 100;
                      if (index == 12) randomHeight = 150 + math.Random().nextDouble() * 30;
                      return Container(
                        width: 4,
                        height: randomHeight,
                        decoration: BoxDecoration(
                          color: index == 12 
                            ? const Color(0xFF00FF41)
                            : const Color(0xFF00FF41).withValues(alpha: index % 3 == 0 ? 0.4 : 0.1),
                          boxShadow: index == 12 ? [
                            const BoxShadow(color: Color(0xFF00FF41), blurRadius: 10),
                          ] : null,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(child: _metricBox("GAIN", "42.0 dB", 0.7, const Color(0xFF00FF41))),
        const SizedBox(width: 12),
        Expanded(child: _metricBox("NOISE FLOOR", "-105 dBm", 0.25, const Color(0xFFFFB4AB))),
      ],
    );
  }

  Widget _metricBox(String label, String value, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 8, color: const Color(0xFF84967E), fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(height: 2, color: Colors.white12),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(height: 2, color: color.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnifferLog() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF353534),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SNIFFER LOG',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: const Color(0xFF84967E))),
                Text('PACKETS: 1,482',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 8, color: const Color(0xFF00FF41))),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return TacticalHover(
                enableNoise: false,
                scale: 1.02,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SIGNAL_RECORDED_TO_LIBRARY'),
                      backgroundColor: Color(0xFF00FF41),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      const Text('[14:22:01]',
                          style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      const Text('@433.92',
                          style: TextStyle(
                              color: Color(0xFF00E3FD),
                              fontSize: 9,
                              fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      const Expanded(
                          child: Text('DATA: 0xAF4B901C77...',
                              style: TextStyle(
                                  color: Color(0xFF00FF41),
                                  fontSize: 9,
                                  fontFamily: 'monospace'))),
                      const Icon(Icons.save_alt,
                          color: Color(0xFF84967E), size: 14),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF00FF41).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var i = 1; i < 6; i++) {
      double x = size.width * (i / 6);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
