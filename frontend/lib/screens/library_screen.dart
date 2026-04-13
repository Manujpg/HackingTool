import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/tactical_hover.dart';
import '../main.dart'; // Wichtig für den Zugriff auf SignalItem

class LibraryScreen extends StatefulWidget {
  final List<SignalItem> signals;
  final Function(int index, String newName) onRename;
  final Function(int index) onDelete;
  final Function(int index) onReplay;

  const LibraryScreen({
    super.key,
    required this.signals,
    required this.onRename,
    required this.onDelete,
    required this.onReplay,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        if (widget.signals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                'NO_SIGNALS_FOUND_IN_REGISTRY',
                style: GoogleFonts.spaceGrotesk(color: Colors.white10, fontSize: 10),
              ),
            ),
          )
        else
        // HIER IST DIE FILTER-LOGIK:
        // .where() filtert die Liste nach dem Suchbegriff, .key behält den Original-Index!
          ...widget.signals.asMap().entries.where((entry) {
            return entry.value.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).map((entry) {
            return _buildSignalBentoCard(context, entry.key, entry.value);
          }),
      ],
    );
  }

  Widget _buildRepositoryStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.2)),
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
                  Text('REPOSITORY_STATUS',
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E), fontSize: 10)),
                  const SizedBox(height: 4),
                  Text('STORAGE_LOAD',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${widget.signals.length} / 64',
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('SLOTS_OCCUPIED',
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E), fontSize: 8)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: widget.signals.length / 64,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF41)),
            minHeight: 2,
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        // HIER WIRD DIE SUCHE AKTUALISIERT:
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'QUERY_SIGNAL_REGISTRY...',
          hintStyle: GoogleFonts.spaceGrotesk(color: const Color(0xFF84967E).withOpacity(0.5), fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF41), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSignalBentoCard(BuildContext context, int index, SignalItem signal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                  Text(signal.name,
                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(signal.frequency,
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 10)),
                ],
              ),
              _badge('RAW_RF'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  label: 'REPLAY',
                  icon: Icons.play_arrow,
                  color: const Color(0xFF00E3FD),
                  onTap: () => widget.onReplay(index),
                ),
              ),
              const SizedBox(width: 8),
              _iconBtn(Icons.edit, Colors.white.withOpacity(0.5), () => _showBrutalistEditDialog(context, index, signal.name)),
              const SizedBox(width: 8),
              _iconBtn(Icons.delete, const Color(0xFFC40015), () => _showBrutalistDeleteDialog(context, index, signal.name)),
            ],
          ),
        ],
      ),
    );
  }

  // --- RENAME POPUP (Grün) ---
  void _showBrutalistEditDialog(BuildContext context, int index, String currentName) {
    final controller = TextEditingController(text: currentName);
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
            color: const Color(0xFF00FF41),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0D0D0D),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EDIT_SIGNAL_ID",
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: GoogleFonts.spaceGrotesk(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.white.withOpacity(0.05),
                      filled: true,
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10), borderRadius: BorderRadius.zero),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41)), borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: GoogleFonts.spaceGrotesk(color: Colors.white24))),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF41), foregroundColor: Colors.black, elevation: 0, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                        onPressed: () {
                          widget.onRename(index, controller.text);
                          Navigator.pop(context);
                        },
                        child: Text("SAVE_CHANGES", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- DELETE POPUP (Rot) ---
  void _showBrutalistDeleteDialog(BuildContext context, int index, String signalName) {
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
            color: const Color(0xFFC40015),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0D0D0D),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFC40015), size: 18),
                      const SizedBox(width: 8),
                      Text("CONFIRM_PURGE_PROTOCOL",
                          style: GoogleFonts.spaceGrotesk(color: const Color(0xFFC40015), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Are you sure you want to permanently delete the signal vector [$signalName]?",
                      style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("ABORT", style: GoogleFonts.spaceGrotesk(color: Colors.white24))),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC40015),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                        ),
                        onPressed: () {
                          widget.onDelete(index);
                          Navigator.pop(context);
                        },
                        child: Text("PURGE", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HILFS-WIDGETS ---
  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF00FF41).withOpacity(0.1), border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3))),
      child: Text(label, style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF41), fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _actionBtn({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return TacticalHover(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.spaceGrotesk(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return TacticalHover(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}