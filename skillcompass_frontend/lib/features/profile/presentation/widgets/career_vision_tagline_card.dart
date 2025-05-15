import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kullanıcının profil sloganını gösteren ve düzenleyen kart widget'ı.
class CareerVisionTaglineCard extends StatelessWidget {
  final String? tagline;
  final bool isEditMode;
  final Function(String) onTaglineChanged;
  final Color mainBlue;
  final Color accentCoral;
  final Color cloudGrey;
  const CareerVisionTaglineCard({
    super.key,
    required this.tagline,
    required this.isEditMode,
    required this.onTaglineChanged,
    required this.mainBlue,
    required this.accentCoral,
    required this.cloudGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil Sloganın',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: mainBlue)),
            const SizedBox(height: 12),
            if (isEditMode)
              TextFormField(
                initialValue: tagline,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Kendini 1 cümleyle tanımlar mısın? (İsteğe bağlı)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: onTaglineChanged,
              )
            else ...[
              Text(
                (tagline ?? '').isNotEmpty ? tagline! : '-',
                style: GoogleFonts.inter(fontSize: 16, color: mainBlue),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 