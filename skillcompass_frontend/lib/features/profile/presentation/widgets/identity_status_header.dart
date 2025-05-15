import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityStatusHeader extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final double progress;
  final Color mainBlue;
  final Color cloudGrey;
  final Color accentBlue;
  final double cardWidth;
  const IdentityStatusHeader({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
    required this.progress,
    required this.mainBlue,
    required this.cloudGrey,
    required this.accentBlue,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    width: (cardWidth - 40) * progress,
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
                '$completedSteps/$totalSteps',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mainBlue, accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.explore, color: Colors.white, size: 36),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(Icons.navigation, color: accentBlue, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kimsiniz ve Neredesiniz?',
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
                    'Bilişim dünyasındaki yerinizi tarif edin. Kendinizi nasıl görüyorsunuz, neyi temsil ediyorsunuz? Bu, kariyer yolculuğunuzun başlangıç noktası.',
                    style: GoogleFonts.inter(fontSize: 16, color: mainBlue),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Rehber butonu ana ekranda kalacak
          ],
        ),
        const SizedBox(height: 10),
        Text('Hikayenizi anlatın, yolculuğunuzu birlikte şekillendirelim!',
          style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600)),
      ],
    );
  }
} 