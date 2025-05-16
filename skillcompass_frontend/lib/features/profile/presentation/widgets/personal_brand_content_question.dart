import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalBrandContentQuestion extends StatefulWidget {
  final List<String>? initialSelected;
  final Function(List<String>)? onChanged;
  const PersonalBrandContentQuestion({Key? key, this.initialSelected, this.onChanged}) : super(key: key);

  @override
  State<PersonalBrandContentQuestion> createState() => _PersonalBrandContentQuestionState();
}

class _PersonalBrandContentQuestionState extends State<PersonalBrandContentQuestion> {
  static const List<String> _contentTypes = [
    'Blog Yazıları ve Makaleler',
    'Proje Tanıtımları (örneğin, GitHub)',
    'Eğitim Videoları veya Canlı Yayınlar',
    'Teknoloji Tartışmaları ve Yorumlar',
    'Diğer',
  ];
  List<String> _selected = [];
  String? _customContent;
  final TextEditingController _customController = TextEditingController();
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelected != null) {
      _selected = List<String>.from(widget.initialSelected!);
    }
  }

  void _onChipTap(String value) {
    setState(() {
      if (value == 'Diğer') {
        _showCustomInput = true;
      } else if (_selected.contains(value)) {
        _selected.remove(value);
      } else if (_selected.length < 3) {
        _selected.add(value);
      }
      widget.onChanged?.call(_selected);
    });
  }

  void _addCustomContent() {
    final text = _customController.text.trim();
    if (text.isNotEmpty && !_selected.contains(text) && _selected.length < 3) {
      setState(() {
        _selected.add(text);
        _customContent = text;
        _customController.clear();
        _showCustomInput = false;
        widget.onChanged?.call(_selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainBlue = const Color(0xFF2A4B7C);
    final gold = const Color(0xFFFFC700);
    final cloudGrey = const Color(0xFFA0AEC0);
    final lightBlue = const Color(0xFF6B7280);
    final successGreen = const Color(0xFF38A169);
    final isComplete = _selected.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Paylaşım içerikleri başlığı',
                child: Text(
                  'Kişisel markanızı güçlendirmek için hangi tür içerikleri paylaşmak istiyorsunuz?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Seçilen içerik türü sayısı',
              child: Text(
                '${_selected.length}/3',
                style: GoogleFonts.inter(fontSize: 14, color: gold, fontWeight: FontWeight.w600),
              ),
            ),
            if (isComplete)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: successGreen, size: 22, semanticLabel: 'Tamamlandı'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _contentTypes.map((content) {
            final isSelected = _selected.contains(content) || (content == 'Diğer' && _showCustomInput);
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(content, style: GoogleFonts.inter(fontSize: 15)),
                  if (content == 'Diğer')
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.add, color: gold, size: 18),
                    ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (content == 'Diğer') {
                  setState(() => _showCustomInput = true);
                } else {
                  _onChipTap(content);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: gold,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : mainBlue,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? gold : cloudGrey,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
        if (_showCustomInput)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: Semantics(
                      label: 'Özel içerik girişi',
                      child: TextField(
                        controller: _customController,
                        maxLength: 30,
                        decoration: InputDecoration(
                          hintText: 'Kendi içerik türünüzü yazın (örneğin, podcast).',
                          hintStyle: GoogleFonts.inter(color: mainBlue, fontSize: 15),
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cloudGrey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: gold, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _customController.text.trim().isEmpty || _selected.length >= 3
                        ? null
                        : _addCustomContent,
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
            ),
          ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Paylaşım içerikleri ipucu',
          child: Text(
            'En fazla 3 içerik türü seçin. Hedef kitlenize uygun içerikler planlayacağız.',
            style: GoogleFonts.inter(fontSize: 14, color: lightBlue),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[700], size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'İpucu: Hedef kitlenizin ilgisini çekecek özgün içerikler seçin.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[800], fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 