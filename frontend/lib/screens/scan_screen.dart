import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ScanScreen extends StatefulWidget {
  final Function(String hex, String freq) onSave;
  const ScanScreen({super.key, required this.onSave});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _freqController;
  double _currentFreq = 433.92;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _freqController = TextEditingController(text: _currentFreq.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _freqController.dispose();
    super.dispose();
  }

  void _updateFrequency(double newFreq) {
    double cappedFreq = newFreq > 999.99 ? 999.99 : (newFreq < 0.0 ? 0.0 : newFreq);
    setState(() {
      _currentFreq = cappedFreq;
      _freqController.text = _currentFreq.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          _buildMetricsRow(),
          const SizedBox(height: 16),
          _buildSnifferLog(),
        ],
      ),
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
              animation: _controller,
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
      decoration: BoxDecoration(color: const Color(0xFF1C1B1B), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF84967E))), Text(value, style: TextStyle(fontSize: 10, color: color))]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, color: color, backgroundColor: Colors.white10, minHeight: 2),
        ],
      ),
    );
  }

  Widget _buildSnifferLog() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF222222), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8), color: const Color(0xFF2A2A2A), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("SNIFFER LOG", style: TextStyle(fontSize: 10)), Text("PACKETS: 1,482", style: TextStyle(fontSize: 8, color: Color(0xFF00FF41)))])),
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