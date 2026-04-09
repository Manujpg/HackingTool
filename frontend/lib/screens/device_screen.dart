import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/tactical_hover.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHardwareHeader(),
        const SizedBox(height: 20),
        _buildSystemMetrics(),
        const SizedBox(height: 20),
        _buildNetworkInterface(),
        const SizedBox(height: 20),
        _buildFirmwareInfo(),
      ],
    );
  }

  Widget _buildHardwareHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: const Color(0xFF00FF41).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF41).withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CORE_HARDWARE_SYSTEM',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF84967E),
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ESP32-S3 WROOM',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.memory, color: Color(0xFF00FF41), size: 32),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statusChip('CPU: 240MHz', true),
              const SizedBox(width: 8),
              _statusChip('RAM: 512KB', true),
              const SizedBox(width: 8),
              _statusChip('TEMP: 42°C', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (ok ? const Color(0xFF00FF41) : const Color(0xFFC40015)).withValues(alpha: 0.1),
        border: Border.all(color: (ok ? const Color(0xFF00FF41) : const Color(0xFFC40015)).withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          color: ok ? const Color(0xFF00FF41) : const Color(0xFFC40015),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSystemMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _metricBox('BATTERY_VOLTAGE', '3.84', 'V', const Color(0xFF00FF41)),
        _metricBox('RF_NOISE_FLOOR', '-104', 'dBm', const Color(0xFF00E3FD)),
        _metricBox('TX_DUTY_CYCLE', '1.2', '%', const Color(0xFF00FF41)),
        _metricBox('UPTIME_HRS', '14.5', 'H', const Color(0xFF84967E)),
      ],
    );
  }

  Widget _metricBox(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E), fontSize: 8)),
          const SizedBox(height: 4),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.spaceGrotesk(color: color.withValues(alpha: 0.5), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NETWORK_INTERFACE',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF00FF41),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow('SSID', 'EW_SECURE_AP'),
          _infoRow('MAC', 'AC:67:B2:44:A1:0F'),
          _infoRow('IP', '192.168.4.1'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _tacticalToggle('WIFI_TRANSCEIVER', true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tacticalToggle('BT_LE_STACK', false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E), fontSize: 11)),
          Text(value, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _tacticalToggle(String label, bool active) {
    return TacticalHover(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00FF41).withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: active
                ? const Color(0xFF00FF41).withValues(alpha: 0.3)
                : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 8)),
            const SizedBox(height: 4),
            Text(
              active ? 'ACTIVE' : 'DISABLED',
              style: GoogleFonts.spaceGrotesk(
                color: active ? const Color(0xFF00FF41) : const Color(0xFF84967E),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirmwareInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC40015).withValues(alpha: 0.2)),
        color: const Color(0xFFC40015).withValues(alpha: 0.02),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFC40015), size: 16),
              const SizedBox(width: 8),
              Text(
                'FIRMWARE_REVISION: v0.9.4b-STABLE',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFC40015),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PLEASE_UPGRADE_TO_STABLE_BUILD_FOR_CRITICAL_SECURITY_PATCHES',
            style: GoogleFonts.spaceGrotesk(color: const Color(0xFFC40015).withValues(alpha: 0.7), fontSize: 8),
          ),
        ],
      ),
    );
  }
}
