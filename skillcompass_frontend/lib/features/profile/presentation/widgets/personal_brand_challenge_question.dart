import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalBrandChallengeQuestion extends StatefulWidget {
  final String? initialChallenge;
  final Function(String)? onChanged;
  const PersonalBrandChallengeQuestion({Key? key, this.initialChallenge, this.onChanged}) : super(key: key);

  @override
  State<PersonalBrandChallengeQuestion> createState() => _PersonalBrandChallengeQuestionState();
}

class _PersonalBrandChallengeQuestionState extends State<PersonalBrandChallengeQuestion> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _inspirationList = [
    'Özgün içerik fikirleri bulmakta zorlanma.',
    'Düzenli paylaşım için zaman bulamamak.',
    'Kitleyle etkileşim kurmakta güçlük.',
    'Platformların algoritmasını anlamamak.',
    'Özgüven eksikliği veya görünür olmaktan çekinmek.',
    'Teknik araçları etkin kullanamamak.',
  ];
  int _inspirationIndex = 0;
  bool _showInspiration = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialChallenge != null) {
      _controller.text = widget.initialChallenge!;
    }
  }

  void _toggleInspiration() {
    setState(() {
      if (_showInspiration) {
        _inspirationIndex = (_inspirationIndex + 1) % _inspirationList.length;
      }
      _showInspiration = !_showInspiration || _showInspiration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainBlue = const Color(0xFF2A4B7C);
    final gold = const Color(0xFFFFC700);
    final lightBlue = const Color(0xFF6B7280);
    final successGreen = const Color(0xFF38A169);
    final darkGrey = const Color(0xFF4A4A4A);
    final isComplete = _controller.text.trim().length >= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Marka oluşturma zorlukları başlığı',
                child: Text(
                  'Kişisel marka oluştururken karşılaştığınız en büyük zorluk nedir?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: mainBlue),
                ),
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
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Marka oluşturma zorlukları girişi',
                child: TextField(
                  controller: _controller,
                  maxLength: 100,
                  onChanged: (val) => widget.onChanged?.call(val),
                  decoration: InputDecoration(
                    hintText: 'Örneğin: Düzenli içerik üretmek için zaman bulamamak.',
                    hintStyle: GoogleFonts.inter(color: mainBlue, fontSize: 16, fontWeight: FontWeight.w500),
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: lightBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: gold, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: GoogleFonts.inter(fontSize: 16, color: mainBlue, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _toggleInspiration,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: gold, size: 24, semanticLabel: 'İlham önerisi göster'),
              ),
            ),
          ],
        ),
        if (_showInspiration)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _InspirationPopup(
              suggestion: _inspirationList[_inspirationIndex],
              mainBlue: mainBlue,
              gold: gold,
              onClose: () => setState(() => _showInspiration = false),
            ),
          ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Marka oluşturma zorlukları ipucu',
          child: Text(
            'Zorluklarınızı dürüstçe paylaşın. Size uygun çözümler ve stratejiler sunacağız.',
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
              Icon(Icons.info_outline, color: darkGrey, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'İpucu: Küçük adımlarla başlayın; haftada bir paylaşım bile etkili olabilir.',
                  style: GoogleFonts.inter(fontSize: 12, color: darkGrey, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InspirationPopup extends StatelessWidget {
  final String suggestion;
  final Color mainBlue;
  final Color gold;
  final VoidCallback onClose;
  const _InspirationPopup({required this.suggestion, required this.mainBlue, required this.gold, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width * 0.9;
    return Semantics(
      label: 'İlham önerisi popup',
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth < 340 ? maxWidth : 340,
            minHeight: 80,
            maxHeight: 180,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: gold, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: mainBlue.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'İlham Önerisi',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: mainBlue),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  suggestion,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  tooltip: 'Kapat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 