import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareerVisionShortTermCard extends StatelessWidget {
  final List<String> goalOptions;
  final String? selectedGoal;
  final String? goalDetail;
  final bool isEditMode;
  final Function(String?) onGoalChanged;
  final Function(String) onDetailChanged;
  final Color mainBlue;
  final Color accentCoral;
  final Color cloudGrey;
  const CareerVisionShortTermCard({
    super.key,
    required this.goalOptions,
    required this.selectedGoal,
    required this.goalDetail,
    required this.isEditMode,
    required this.onGoalChanged,
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
            Text('1 Yıllık Hedefin',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: mainBlue)),
            const SizedBox(height: 12),
            if (isEditMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGoal,
                    items: goalOptions
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                    onChanged: onGoalChanged,
                    decoration: InputDecoration(
                      labelText: 'Hedef Seç',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: goalDetail,
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
              Text(selectedGoal ?? '-', style: GoogleFonts.inter(fontSize: 16, color: mainBlue)),
              if ((goalDetail ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(goalDetail!, style: GoogleFonts.inter(fontSize: 15, color: cloudGrey)),
              ]
            ],
          ],
        ),
      ),
    );
  }
} 