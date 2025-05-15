import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityClarityCard extends StatelessWidget {
  final double clarity;
  final ValueChanged<double> onChanged;
  final String clarityText;
  const IdentityClarityCard({
    super.key,
    required this.clarity,
    required this.onChanged,
    required this.clarityText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kariyer kimliğiniz ne kadar net?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor)),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey,
            thumbColor: Colors.orange,
            overlayColor: Colors.orange.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: clarity,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),
        Text(clarityText, style: GoogleFonts.inter(fontSize: 14)),
        const SizedBox(height: 6),
        Text('Ne kadar net olduğunuzu dürüstçe değerlendirin. Bu, size en uygun önerileri sunmamızı sağlayacak.',
          style: GoogleFonts.inter(fontSize: 14)),
      ],
    );
  }
} 