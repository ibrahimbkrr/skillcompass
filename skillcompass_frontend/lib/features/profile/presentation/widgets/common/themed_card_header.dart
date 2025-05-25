import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemedCardHeader extends StatelessWidget {
  final String title;
  final String description;
  final Color mainColor;
  final Color accentColor;
  final VoidCallback? onGuide;
  final Widget? progressWidget;
  final IconData? icon;
  const ThemedCardHeader({
    Key? key,
    required this.title,
    required this.description,
    this.mainColor = const Color(0xFF2A4B7C),
    this.accentColor = const Color(0xFFFF6B6B),
    this.onGuide,
    this.progressWidget,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mainColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon ?? Icons.assignment_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: mainColor,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: mainColor.withOpacity(0.7),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onGuide != null)
              IconButton(
                icon: Icon(Icons.info_outline_rounded, color: accentColor, size: 26),
                onPressed: onGuide,
                tooltip: 'Rehber',
              ),
          ],
        ),
        if (progressWidget != null) ...[
          const SizedBox(height: 10),
          progressWidget!,
        ],
      ],
    );
  }
} 