import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentConnectionsQuestion extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onChanged;
  final String customValue;
  final ValueChanged<String> onCustomChanged;
  final VoidCallback onAddCustom;
  final bool canAddCustom;
  final bool completed;
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final Color lightBlue;
  final Color successGreen;
  const CurrentConnectionsQuestion({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.customValue,
    required this.onCustomChanged,
    required this.onAddCustom,
    required this.canAddCustom,
    required this.completed,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    required this.lightBlue,
    required this.successGreen,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      'İş Arkadaşları ve Ekip Üyeleri',
      'Bilişim Toplulukları ve Etkinlikler',
      'Eğitim veya Mentorluk Grupları',
      'Sosyal Medya ve Online Platformlar',
      'Diğer',
    ];
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            border: Border.all(
              color: completed ? gold : cloudGrey,
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
                      label: 'Mevcut bağlantılar başlığı',
                      child: Text(
                        'Şu anda hangi profesyonel bağlantılara sahipsiniz?',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: mainBlue),
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Seçilen bağlantı sayısı',
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
                  if (completed)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.check_circle, color: successGreen, size: 22),
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
                    label: option == 'Diğer'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, color: Color(0xFFFFC107), size: 18),
                              const SizedBox(width: 4),
                              Text(option),
                            ],
                          )
                        : Text(option),
                    selected: isSelected,
                    onSelected: (selected.length < 3 || isSelected)
                        ? (_) => onChanged(option)
                        : null,
                    backgroundColor: Colors.white,
                    selectedColor: gold,
                    side: BorderSide(color: isSelected ? gold : cloudGrey, width: 1.5),
                    labelStyle: GoogleFonts.inter(
                      color: isSelected ? Colors.white : mainBlue,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
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
                        label: 'Özel bağlantı girişi',
                        child: TextFormField(
                          initialValue: customValue,
                          maxLength: 30,
                          onChanged: onCustomChanged,
                          style: GoogleFonts.inter(fontSize: 15, color: mainBlue),
                          decoration: InputDecoration(
                            hintText: 'Kendi bağlantı türünüzü yazın.',
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
                      onPressed: canAddCustom ? onAddCustom : null,
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
                label: 'Bağlantı seçimi ipucu',
                child: Text(
                  'En fazla 3 bağlantı türü seçin. Mevcut ağınızı anlamak önerilerimizi güçlendirecek.',
                  style: GoogleFonts.inter(fontSize: 14, color: lightBlue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 