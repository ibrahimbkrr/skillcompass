import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningStyleBarrierCard extends StatelessWidget {
  final TextEditingController barrierController;
  final String barrier;
  final bool showInspirePopup;
  final int inspireIndex;
  final List<String> inspireList;
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final Color lightBlue;
  final VoidCallback onInspireTap;
  final Function(String) onChanged;
  const LearningStyleBarrierCard({
    super.key,
    required this.barrierController,
    required this.barrier,
    required this.showInspirePopup,
    required this.inspireIndex,
    required this.inspireList,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    required this.lightBlue,
    required this.onInspireTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double _responsiveFont(num base) {
      final scale = MediaQuery.of(context).textScaleFactor;
      return (base * scale).clamp(16, 20).toDouble();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Öğrenme sürecinizde en büyük engeliniz nedir?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _responsiveFont(18),
                  color: mainBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onInspireTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: mainBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: gold, size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: barrierController,
          maxLength: 100,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: _responsiveFont(16),
            color: mainBlue,
          ),
          decoration: InputDecoration(
            hintText: 'Örneğin: Zaman yönetimi veya karmaşık konular.',
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cloudGrey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: gold, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintStyle: GoogleFonts.inter(color: lightBlue),
          ),
          onChanged: onChanged,
        ),
        if (showInspirePopup)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AnimatedOpacity(
              opacity: showInspirePopup ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(inspireList[inspireIndex], style: GoogleFonts.inter(fontSize: 14, color: mainBlue)),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          'Engellerinizi dürüstçe paylaşın. Size uygun çözümler önereceğiz.',
          style: GoogleFonts.inter(
            fontSize: _responsiveFont(14),
            color: lightBlue,
          ),
        ),
      ],
    );
  }
} 