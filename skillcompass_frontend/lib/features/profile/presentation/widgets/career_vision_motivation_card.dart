import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kullanıcının kariyer motivasyon kaynaklarını gösteren ve düzenleyen kart widget'ı.
class CareerVisionMotivationCard extends StatelessWidget {
  final List<String> motivationOptions;
  final List<String> selectedMotivations;
  final bool isEditMode;
  final Function(String) onMotivationToggle;
  final Color mainBlue;
  final Color accentCoral;
  final Color cloudGrey;
  const CareerVisionMotivationCard({
    super.key,
    required this.motivationOptions,
    required this.selectedMotivations,
    required this.isEditMode,
    required this.onMotivationToggle,
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
            Text('Motivasyon Kaynakların',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: mainBlue)),
            const SizedBox(height: 12),
            if (isEditMode)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: motivationOptions.map((option) {
                  final isSelected = selectedMotivations.contains(option);
                  return FilterChip(
                    label: Text(option,
                        style: GoogleFonts.inter(
                          color: isSelected ? mainBlue : cloudGrey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        )),
                    selected: isSelected,
                    onSelected: (_) => onMotivationToggle(option),
                    backgroundColor: cloudGrey.withOpacity(0.1),
                    selectedColor: accentCoral.withOpacity(0.2),
                    checkmarkColor: accentCoral,
                  );
                }).toList(),
              )
            else ...[
              if (selectedMotivations.isEmpty)
                Text('-', style: GoogleFonts.inter(fontSize: 16, color: cloudGrey)),
              if (selectedMotivations.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedMotivations.map((item) => Chip(
                    label: Text(item, style: GoogleFonts.inter(color: mainBlue)),
                    backgroundColor: accentCoral.withOpacity(0.1),
                  )).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
} 