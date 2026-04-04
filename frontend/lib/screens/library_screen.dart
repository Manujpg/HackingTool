import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/tactical_hover.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRepositoryStatus(),
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 20),
        Text(
          'REGISTERED_SIGNALS',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF00FF41),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        _buildSignalBentoCard(
          name: 'GARAGE_ENTRY_01',
          frequency: '433.92 MHZ',
          protocol: 'OOK_RAW',
          timestamp: '2023-10-24 14:22:01',
          color: const Color(0xFF00FF41),
        ),
        _buildSignalBentoCard(
          name: 'WORK_PASS_NFC',
          frequency: '13.56 MHZ',
          protocol: 'ISO_14443A',
          timestamp: '2023-11-02 08:45:12',
          color: const Color(0xFF00E3FD),
        ),
        _buildSignalBentoCard(
          name: 'AC_REMOTE_SEC',
          frequency: '868.30 MHZ',
          protocol: 'FSK_DATA',
          timestamp: '2023-11-15 19:10:44',
          color: const Color(0xFF00FF41),
        ),
      ],
    );
  }

  Widget _buildRepositoryStatus() {
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
                    'REPOSITORY_STATUS',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF84967E),
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'STORAGE_LOAD',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '18 / 64',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF00FF41),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'SLOTS_OCCUPIED',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF84967E),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: LinearProgressIndicator(
              value: 18 / 64,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF41)),
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'QUERY_SIGNAL_REGISTRY...',
          hintStyle: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF84967E).withValues(alpha: 0.5),
            fontSize: 12,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF41), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSignalBentoCard({
    required String name,
    required String frequency,
    required String protocol,
    required String timestamp,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    frequency,
                    style: GoogleFonts.spaceGrotesk(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  protocol,
                  style: GoogleFonts.spaceGrotesk(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, size: 10, color: Color(0xFF84967E)),
              const SizedBox(width: 4),
              Text(
                'RECORDED: $timestamp',
                style: GoogleFonts.inter(
                  color: const Color(0xFF84967E),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _tacticalButton(
                  label: 'REPLAY',
                  icon: Icons.play_arrow,
                  color: const Color(0xFF00E3FD),
                ),
              ),
              const SizedBox(width: 8),
              _iconAction(Icons.edit, Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              _iconAction(Icons.delete, const Color(0xFFC40015)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tacticalButton(
      {required String label, required IconData icon, required Color color}) {
    return TacticalHover(
      onTap: () {},
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color) {
    return TacticalHover(
      onTap: () {},
      scale: 1.1,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
