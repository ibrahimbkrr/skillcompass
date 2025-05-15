import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kullanıcının 5 yıllık kariyer vizyonunu gösteren ve düzenleyen kart widget'ı.
class CareerVisionLongTermCard extends StatelessWidget {
  final List<String> visionOptions;
  final String? selectedVision;
  final String? visionDetail;
  final bool isEditMode;
  final Function(String?) onVisionChanged;
  final Function(String) onDetailChanged;
  final Color mainBlue;
  final Color accentCoral;
  final Color cloudGrey;
  const CareerVisionLongTermCard({
    super.key,
    required this.visionOptions,
    required this.selectedVision,
    required this.visionDetail,
    required this.isEditMode,
    required this.onVisionChanged,
    required this.onDetailChanged,
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
            Text('5 Yıllık Vizyonun',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: mainBlue)),
            const SizedBox(height: 12),
            if (isEditMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedVision,
                    items: visionOptions
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                    onChanged: onVisionChanged,
                    decoration: InputDecoration(
                      labelText: 'Vizyon Seç',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: visionDetail,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Detay ekle (isteğe bağlı)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: onDetailChanged,
                  ),
                ],
              )
            else ...[
              Text(selectedVision ?? '-', style: GoogleFonts.inter(fontSize: 16, color: mainBlue)),
              if ((visionDetail ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(visionDetail!, style: GoogleFonts.inter(fontSize: 15, color: cloudGrey)),
              ]
            ],
          ],
        ),
      ),
    );
  }
} 