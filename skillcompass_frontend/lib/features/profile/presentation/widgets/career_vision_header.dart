import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareerVisionHeader extends StatelessWidget {
  final Color mainBlue;
  final Color accentCoral;
  final VoidCallback? onGuide;
  const CareerVisionHeader({
    super.key,
    required this.mainBlue,
    required this.accentCoral,
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mainBlue, accentCoral],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.flag_rounded, color: accentCoral, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kariyer Vizyonun',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: mainBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kısa ve uzun vadeli hedeflerini, motivasyon kaynaklarını ve kariyer vizyonunu paylaş.',
                    style: GoogleFonts.inter(fontSize: 16, color: mainBlue),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onGuide != null)
              IconButton(
                icon: Icon(Icons.info_outline, color: accentCoral, size: 28),
                onPressed: onGuide,
                tooltip: 'Rehber',
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Hedeflerini netleştir, yol haritanı oluştur!',
          style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
} 