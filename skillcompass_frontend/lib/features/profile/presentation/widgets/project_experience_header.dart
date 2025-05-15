import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectExperienceHeader extends StatelessWidget {
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final VoidCallback? onGuide;
  const ProjectExperienceHeader({
    super.key,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    this.onGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simge kutusu (roket veya kod simgesi)
            Semantics(
              label: 'Proje deneyimi simgesi',
              container: true,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mainBlue, gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Proje deneyimi başlığı',
                    child: Text(
                      'Proje Deneyiminizi Paylaşın',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: mainBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    label: 'Proje deneyimi açıklaması',
                    child: Text(
                      'Bilişim projeleriniz neler? Geçmiş deneyimlerinizi ve gelecek hedeflerinizi paylaşın, teknik yolculuğunuzu güçlendirelim.',
                      style: GoogleFonts.inter(fontSize: 16, color: cloudGrey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (onGuide != null)
              Semantics(
                label: 'Rehber',
                button: true,
                child: IconButton(
                  icon: Icon(Icons.explore, color: gold, size: 28),
                  onPressed: onGuide,
                  tooltip: 'Rehber',
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Proje deneyimi motivasyonel metin',
          child: Text(
            'Projelerinizle fark yaratın, becerilerinizi sergileyin!',
            style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
} 