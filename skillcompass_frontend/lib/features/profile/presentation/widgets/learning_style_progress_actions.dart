import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningStyleProgressActions extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final Color mainBlue;
  final Color accentCoral;
  final Color cloudGrey;
  final Color darkGrey;
  final Color lightBlue;
  final bool isSaveEnabled;
  final VoidCallback onSave;
  final VoidCallback onBack;
  const LearningStyleProgressActions({
    super.key,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.mainBlue,
    required this.accentCoral,
    required this.cloudGrey,
    required this.darkGrey,
    required this.lightBlue,
    required this.isSaveEnabled,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    double _responsiveFont(num base) {
      final scale = MediaQuery.of(context).textScaleFactor;
      return (base * scale).clamp(16, 20).toDouble();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: cloudGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 7,
                    width: progress,
                    decoration: BoxDecoration(
                      color: mainBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.explore, color: mainBlue, size: 20),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: mainBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: GoogleFonts.inter(
                  fontSize: _responsiveFont(14),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isSaveEnabled ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaveEnabled ? accentCoral : cloudGrey,
              foregroundColor: isSaveEnabled ? Colors.white : darkGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: _responsiveFont(18),
              ),
              elevation: 0,
            ),
            child: const Text('Kaydet ve İlerle'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Öğrenme stilinizi tanımlayarak yolculuğunuzu güçlendirin.',
          style: GoogleFonts.inter(
            fontSize: _responsiveFont(14),
            color: lightBlue,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF6B7280),
              size: 24,
            ),
            onPressed: onBack,
            tooltip: 'Geri',
          ),
        ),
      ],
    );
  }
} 