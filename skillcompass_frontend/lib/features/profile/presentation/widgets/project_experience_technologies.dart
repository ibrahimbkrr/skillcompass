import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectExperienceTechnologies extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final String customTech;
  final ValueChanged<String> onCustomTechChanged;
  final VoidCallback onAddCustomTech;
  final bool canAddCustomTech;
  final ValueChanged<String> onChipTap;
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final Color lightBlue;
  final TextEditingController customTechController;
  const ProjectExperienceTechnologies({
    super.key,
    required this.options,
    required this.selected,
    required this.customTech,
    required this.onCustomTechChanged,
    required this.onAddCustomTech,
    required this.canAddCustomTech,
    required this.onChipTap,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    required this.lightBlue,
    required this.customTechController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected.isNotEmpty ? gold : cloudGrey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Kullanılan teknolojiler başlığı',
                  child: Text(
                    'Projelerinizde hangi teknolojileri veya araçları kullandınız?',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: mainBlue),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Seçilen teknoloji sayısı',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selected.length}/3',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selected.contains(option);
              return ChoiceChip(
                label: Text(option,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : mainBlue,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                selected: isSelected,
                onSelected: selected.length < 3 || isSelected ? (_) => onChipTap(option) : null,
                backgroundColor: Colors.white,
                selectedColor: gold,
                side: BorderSide(color: isSelected ? gold : cloudGrey, width: 1.5),
                avatar: option == 'Diğer'
                    ? Icon(Icons.add, color: gold, size: 18)
                    : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              );
            }).toList(),
          ),
          if (selected.contains('Diğer')) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Özel teknoloji girişi',
                    child: TextFormField(
                      controller: customTechController,
                      maxLength: 30,
                      onChanged: onCustomTechChanged,
                      style: GoogleFonts.inter(fontSize: 16, color: mainBlue),
                      decoration: InputDecoration(
                        hintText: 'Kendi teknolojilerinizi yazın.',
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: cloudGrey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: gold, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canAddCustomTech ? onAddCustomTech : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Semantics(
            label: 'Teknoloji seçimi ipucu',
            child: Text(
              'En fazla 3 teknoloji veya araç seçin. Bu, beceri profilinizi güçlendirecek.',
              style: GoogleFonts.inter(fontSize: 14, color: lightBlue),
            ),
          ),
        ],
      ),
    );
  }
} 