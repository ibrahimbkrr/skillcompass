import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningStyleResourcesCard extends StatelessWidget {
  final List<String> resourceOptions;
  final List<String> selectedResources;
  final bool showCustomResourceInput;
  final TextEditingController customResourceController;
  final String customResource;
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final Color lightBlue;
  final Function(String, bool) onOptionSelected;
  final Function(String) onCustomChanged;
  final VoidCallback onCustomAdd;
  const LearningStyleResourcesCard({
    super.key,
    required this.resourceOptions,
    required this.selectedResources,
    required this.showCustomResourceInput,
    required this.customResourceController,
    required this.customResource,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    required this.lightBlue,
    required this.onOptionSelected,
    required this.onCustomChanged,
    required this.onCustomAdd,
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
                'Hangi kaynakları öğrenme sürecinizde sık kullanıyorsunuz?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _responsiveFont(18),
                  color: mainBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${selectedResources.length}/3',
              style: GoogleFonts.inter(
                fontSize: _responsiveFont(14),
                color: gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: resourceOptions.map((option) {
            final selected = selectedResources.contains(option);
            return ChoiceChip(
              label: Text(
                option,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : mainBlue,
                ),
              ),
              selected: selected,
              backgroundColor: Colors.white,
              selectedColor: gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: selected ? gold : cloudGrey, width: 1.5),
              ),
              onSelected: (val) => onOptionSelected(option, val),
              avatar: option == 'Diğer' ? Icon(Icons.add, size: 18, color: gold) : null,
            );
          }).toList(),
        ),
        if (showCustomResourceInput) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customResourceController,
                  maxLength: 30,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: _responsiveFont(15),
                    color: mainBlue,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Kendi kaynağınızı yazın',
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
                  onChanged: onCustomChanged,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: customResource.trim().isNotEmpty && selectedResources.length < 3 ? onCustomAdd : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Text('Ekle'),
              ),
            ],
          ),
          if (selectedResources.where((r) => !resourceOptions.contains(r)).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
              child: Wrap(
                spacing: 8,
                children: selectedResources
                    .where((r) => !resourceOptions.contains(r))
                    .map((resource) => Chip(
                          label: Text(resource),
                          onDeleted: () => onOptionSelected(resource, false),
                        ))
                    .toList(),
              ),
            ),
        ],
        const SizedBox(height: 10),
        Text(
          'En fazla 3 kaynağı seçin. Bu, öğrenme önerilerimizi şekillendirecek.',
          style: GoogleFonts.inter(
            fontSize: _responsiveFont(14),
            color: lightBlue,
          ),
        ),
      ],
    );
  }
} 