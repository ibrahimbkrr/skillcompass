import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectExperienceProgressActions extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final bool canSave;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final Color mainBlue;
  final Color gold;
  final Color coral;
  final Color cloudGrey;
  final Color lightBlue;
  const ProjectExperienceProgressActions({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.canSave,
    required this.isSaving,
    required this.onSave,
    required this.onBack,
    required this.mainBlue,
    required this.gold,
    required this.coral,
    required this.cloudGrey,
    required this.lightBlue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completedCount / totalCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            return Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: cloudGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 7,
                        width: barWidth * progress,
                        decoration: BoxDecoration(
                          color: mainBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.rocket_launch_rounded, color: mainBlue, size: 20),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: mainBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedCount/$totalCount',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Semantics(
              label: 'Geri',
              button: true,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: lightBlue, size: 24),
                onPressed: onBack,
                tooltip: 'Geri',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 52,
                decoration: BoxDecoration(
                  color: canSave ? coral : cloudGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: canSave && !isSaving ? onSave : null,
                    child: Center(
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Kaydet ve İlerle',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: canSave ? Colors.white : Colors.black54,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Kart tamamlama ipucu',
          child: Text(
            'Projelerinizi tanımlayarak teknik profilinizi güçlendirin.',
            style: GoogleFonts.inter(fontSize: 14, color: lightBlue),
          ),
        ),
      ],
    );
  }
} 