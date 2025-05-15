import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningStylePreferenceCard extends StatelessWidget {
  final List<String> preferenceOptions;
  final String? selectedPreference;
  final bool showCustomPreferenceInput;
  final TextEditingController customPreferenceController;
  final String customPreference;
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final Color lightBlue;
  final Function(String, bool) onOptionSelected;
  final Function(String) onCustomChanged;
  final VoidCallback onCustomAdd;
  const LearningStylePreferenceCard({
    super.key,
    required this.preferenceOptions,
    required this.selectedPreference,
    required this.showCustomPreferenceInput,
    required this.customPreferenceController,
    required this.customPreference,
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
        Text(
          'Bilişim konularını öğrenirken en çok hangi yöntemi tercih edersiniz?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: _responsiveFont(18),
            color: mainBlue,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: preferenceOptions.map((option) {
            final selected = selectedPreference == option;
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
        if (showCustomPreferenceInput) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customPreferenceController,
                  maxLength: 30,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: _responsiveFont(15),
                    color: mainBlue,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Kendi yönteminizi yazın',
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
                onPressed: customPreference.trim().isNotEmpty ? onCustomAdd : null,
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
        ],
        const SizedBox(height: 10),
        Text(
          'Size en uygun öğrenme yöntemini seçin. Bu, önerilerimizi kişiselleştirecek.',
          style: GoogleFonts.inter(
            fontSize: _responsiveFont(14),
            color: lightBlue,
          ),
        ),
      ],
    );
  }
} 