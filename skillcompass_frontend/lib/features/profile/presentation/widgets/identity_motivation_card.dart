import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityMotivationCard extends StatelessWidget {
  final List<String> motivationOptions;
  final List<String> selectedMotivations;
  final bool showCustomMotivation;
  final TextEditingController customMotivationController;
  final Function(String, bool) onMotivationSelected;
  final Function(String) onCustomMotivationChanged;
  const IdentityMotivationCard({
    super.key,
    required this.motivationOptions,
    required this.selectedMotivations,
    required this.showCustomMotivation,
    required this.customMotivationController,
    required this.onMotivationSelected,
    required this.onCustomMotivationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Sizi motive eden nedir?',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor)),
            ),
            const SizedBox(width: 8),
            Text('${selectedMotivations.length + (showCustomMotivation && customMotivationController.text.trim().isNotEmpty ? 1 : 0)}/3',
              style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).primaryColor)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: motivationOptions.map((motivation) {
            final selected = selectedMotivations.contains(motivation);
            return ChoiceChip(
              label: Text(motivation, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: selected ? Colors.white : Theme.of(context).primaryColor)),
              selected: selected,
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: selected ? Theme.of(context).primaryColor : Colors.grey, width: 1.5),
              ),
              onSelected: (val) => onMotivationSelected(motivation, val),
              avatar: motivation == 'Diğer' ? const Icon(Icons.add, size: 18) : null,
            );
          }).toList(),
        ),
        if (showCustomMotivation) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: customMotivationController,
            maxLength: 30,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Kendi motivasyonunuzu yazın',
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onChanged: onCustomMotivationChanged,
          ),
        ],
        const SizedBox(height: 6),
        Text('Sizi sabah yataktan kaldıran şey nedir? Birden fazla seçebilirsiniz.',
          style: GoogleFonts.inter(fontSize: 14)),
      ],
    );
  }
} 