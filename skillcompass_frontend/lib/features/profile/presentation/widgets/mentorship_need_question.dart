import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MentorshipNeedQuestion extends StatelessWidget {
  final String value;
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
  const MentorshipNeedQuestion({
    super.key,
    required this.value,
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
      'Teknik Beceri Geliştirme',
      'Kariyer Planlama ve Rehberlik',
      'Proje Yönetimi ve Liderlik',
      'Networking ve Tanıtım',
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
                      label: 'Mentorluk ihtiyacı başlığı',
                      child: Text(
                        'Bilişim kariyerinizde ne tür bir mentorluk arıyorsunuz?',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: mainBlue),
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
                  final isSelected = value == option || (option == 'Diğer' && value.isNotEmpty && !options.contains(value));
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
                    onSelected: (_) {
                      if (option == 'Diğer') {
                        onChanged('');
                      } else {
                        onChanged(option);
                      }
                    },
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
              if (value == '' || (!options.contains(value) && value.isNotEmpty)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Özel mentorluk girişi',
                        child: TextFormField(
                          initialValue: customValue,
                          maxLength: 30,
                          onChanged: onCustomChanged,
                          style: GoogleFonts.inter(fontSize: 15, color: mainBlue),
                          decoration: InputDecoration(
                            hintText: 'Kendi mentorluk ihtiyacınızı yazın.',
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
                label: 'Mentorluk ihtiyacı ipucu',
                child: Text(
                  'Size en uygun mentorluk türünü seçin. Bu, doğru rehberi bulmamızı sağlayacak.',
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