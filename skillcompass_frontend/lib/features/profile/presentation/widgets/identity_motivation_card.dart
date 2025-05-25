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
    final String customMotivation = customMotivationController.text.trim();
    final bool hasCustom = showCustomMotivation && customMotivation.isNotEmpty;
    final List<String> allSelected = [
      ...selectedMotivations,
      if (hasCustom && !selectedMotivations.contains(customMotivation)) customMotivation,
    ];
    final int selectedCount = selectedMotivations.length;
    final bool limitReached = selectedCount >= 3;
    final bool customAdded = selectedMotivations.contains(customMotivation) && customMotivation.isNotEmpty;
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
            Text('${selectedCount > 3 ? 3 : selectedCount}/3',
              style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).primaryColor)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...motivationOptions.map((motivation) {
              final selected = selectedMotivations.contains(motivation);
              final bool disabled = limitReached && !selected;
              return ChoiceChip(
                label: Text(
                  motivation,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : disabled
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                  ),
                ),
                selected: selected,
                backgroundColor: selected
                    ? Theme.of(context).primaryColor
                    : disabled
                        ? Colors.grey.shade200
                        : Colors.white,
                selectedColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selected
                        ? Theme.of(context).primaryColor
                        : disabled
                            ? Colors.grey.shade400
                            : Colors.grey,
                    width: 1.5,
                  ),
                ),
                onSelected: disabled ? null : (val) => onMotivationSelected(motivation, val),
                avatar: motivation == 'Diğer' ? const Icon(Icons.add, size: 18) : null,
              );
            }),
            if (customAdded)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Chip(
                  label: Text(
                    customMotivation,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                  onDeleted: () {
                    customMotivationController.clear();
                    onCustomMotivationChanged('');
                    onMotivationSelected(customMotivation, false);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
        if (showCustomMotivation) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
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
                  enabled: !limitReached || customAdded,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (!limitReached && customMotivation.isNotEmpty && !customAdded)
                    ? () => onMotivationSelected(customMotivation, true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Text('Ekle'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Text('Sizi sabah yataktan kaldıran şey nedir? Birden fazla seçebilirsiniz.',
          style: GoogleFonts.inter(fontSize: 14)),
      ],
    );
  }
} 