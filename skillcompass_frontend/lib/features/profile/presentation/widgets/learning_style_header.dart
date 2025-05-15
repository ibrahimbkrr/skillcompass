import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningStyleHeader extends StatelessWidget {
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final VoidCallback onGuide;
  const LearningStyleHeader({
    super.key,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    required this.onGuide,
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
                  colors: [mainBlue, gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.menu_book_rounded, color: gold, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Öğrenme Stilinizi Keşfedin',
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
                    'Bilişim dünyasında nasıl öğreniyorsunuz? Tercihlerinizi paylaşın, size özel bir öğrenme planı oluşturalım.',
                    style: GoogleFonts.inter(fontSize: 16, color: cloudGrey),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.explore, color: gold, size: 28),
              onPressed: onGuide,
              tooltip: 'Rehber',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Öğrenme yolculuğunuzu şekillendirmek için ilk adımı atın!',
          style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
} 