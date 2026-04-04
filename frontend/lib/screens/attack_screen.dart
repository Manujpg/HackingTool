import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/tactical_hover.dart';

class AttackScreen extends StatefulWidget {
  const AttackScreen({super.key});

  @override
  State<AttackScreen> createState() => _AttackScreenState();
}

class _AttackScreenState extends State<AttackScreen> {
  bool _isEngaged = false;
  double _powerLevel = 0.65;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOperationalStatus(),
        const SizedBox(height: 20),
        _buildJammingControls(),
        const SizedBox(height: 20),
        _buildTerminalOutput(),
        const SizedBox(height: 20),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildOperationalStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border(
          left: BorderSide(
            color: _isEngaged ? const Color(0xFFC40015) : const Color(0xFF00FF41),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SYSTEM_OPERATIONAL_STATE',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF84967E),
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                _isEngaged ? 'TRANSMITTING' : 'IDLE',
                style: GoogleFonts.spaceGrotesk(
                  color: _isEngaged ? const Color(0xFFC40015) : const Color(0xFF00FF41),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isEngaged ? 'JAMMING_ACTIVE' : 'READY_TO_ENGAGE',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statusIndicator('CC1101', true),
              const SizedBox(width: 12),
              _statusIndicator('ANTENNA', true),
              const SizedBox(width: 12),
              _statusIndicator('TX_LOCK', !_isEngaged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusIndicator(String label, bool active) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00FF41) : const Color(0xFFC40015),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: active ? const Color(0xFF00FF41) : const Color(0xFFC40015),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF84967E),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildJammingControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INTERFERENCE_PARAMETERS',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF00E3FD),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _controlRow('TARGET_FREQ', '433.92 MHz'),
          const SizedBox(height: 12),
          _controlRow('WAVEFORM', 'NOISE_FLOOD'),
          const SizedBox(height: 24),
          Text(
            'OUTPUT_POWER: ${(_powerLevel * 100).toInt()}%',
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 11),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E3FD),
              inactiveTrackColor: Colors.white10,
              thumbColor: const Color(0xFF00E3FD),
              overlayColor: const Color(0xFF00E3FD).withValues(alpha: 0.1),
              trackHeight: 2,
            ),
            child: Slider(
              value: _powerLevel,
              onChanged: (v) => setState(() => _powerLevel = v),
            ),
          ),
          const SizedBox(height: 12),
          TacticalHover(
            onTap: () => setState(() => _isEngaged = !_isEngaged),
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isEngaged
                    ? const Color(0xFFC40015).withValues(alpha: 0.2)
                    : const Color(0xFF00FF41).withValues(alpha: 0.1),
                border: Border.all(
                  color: _isEngaged
                      ? const Color(0xFFC40015)
                      : const Color(0xFF00FF41),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _isEngaged ? 'CEASE_TRANSMISSION' : 'ENGAGE_SYSTEM',
                  style: GoogleFonts.spaceGrotesk(
                    color: _isEngaged
                        ? const Color(0xFFC40015)
                        : const Color(0xFF00FF41),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E), fontSize: 11)),
        Text(value, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTerminalOutput() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Color(0xFF00FF41), size: 14),
              const SizedBox(width: 8),
              Text(
                'LIVE_SIGNAL_LOG',
                style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Expanded(
            child: ListView(
              children: [
                _logLine('14:22:01', 'TX_INIT', 'CALIBRATING OSCILLATOR...'),
                _logLine('14:22:02', 'TX_READY', 'CC1101 LOCK ACQUIRED'),
                if (_isEngaged) _logLine('14:22:05', 'JAMMING', 'BROADCASTING AT 433.92 MHZ'),
                if (_isEngaged) _logLine('14:22:06', 'POWER', 'PEAK AMPLITUDE DETECTED'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logLine(String time, String tag, String msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.spaceGrotesk(fontSize: 9),
          children: [
            TextSpan(text: '[$time] ', style: const TextStyle(color: Color(0xFF84967E))),
            TextSpan(text: '$tag: ', style: const TextStyle(color: Color(0xFF00E3FD), fontWeight: FontWeight.bold)),
            TextSpan(text: msg, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _quickAction('REPLAY_SIGNAL', Icons.repeat, const Color(0xFF00E3FD)),
        _quickAction('ROLLING_CODE', Icons.security, const Color(0xFF00FF41)),
        _quickAction('DEAUTH_WIFI', Icons.wifi_off, const Color(0xFFC40015)),
        _quickAction('GPS_SPOOF', Icons.location_off, Colors.orange),
      ],
    );
  }

  Widget _quickAction(String label, IconData icon, Color color) {
    return TacticalHover(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
