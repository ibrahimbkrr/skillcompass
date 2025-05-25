import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileProgressHeader extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final double progress;
  final Color mainColor;
  final Color accentColor;
  final double cardWidth;
  final IconData icon;
  final String title;
  final String description;
  final String? subtitle;
  const ProfileProgressHeader({
    Key? key,
    required this.completedSteps,
    required this.totalSteps,
    required this.progress,
    required this.mainColor,
    required this.accentColor,
    required this.cardWidth,
    required this.icon,
    required this.title,
    required this.description,
    this.subtitle,
  }) : super(key: key);

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
                      color: accentColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 7,
                    width: (cardWidth - 40) * progress,
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: mainColor, size: 20),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: mainColor,
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
                  colors: [mainColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: mainColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(fontSize: 16, color: mainColor),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: GoogleFonts.inter(fontSize: 15, color: mainColor, fontWeight: FontWeight.w600)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 