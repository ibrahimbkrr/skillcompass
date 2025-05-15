import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NetworkingGoalQuestion extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onInspireTap;
  final bool showInspirePopup;
  final String inspireText;
  final bool completed;
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final Color lightBlue;
  final Color successGreen;
  const NetworkingGoalQuestion({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onInspireTap,
    required this.showInspirePopup,
    required this.inspireText,
    required this.completed,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    required this.lightBlue,
    required this.successGreen,
  });

  @override
  Widget build(BuildContext context) {
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
                      label: 'Networking hedefi başlığı',
                      child: Text(
                        'Bir yıl içinde networking açısından neyi başarmak istiyorsunuz?',
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Networking hedefi girişi',
                      child: TextFormField(
                        initialValue: value,
                        maxLength: 100,
                        minLines: 1,
                        maxLines: 3,
                        onChanged: onChanged,
                        style: GoogleFonts.inter(fontSize: 16, color: mainBlue, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Örneğin: Bir bilişim konferansında 10 yeni bağlantı kurmak.',
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
                  Semantics(
                    label: 'İlham önerisi göster',
                    button: true,
                    child: GestureDetector(
                      onTap: onInspireTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lightbulb, color: gold, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Networking hedefi ipucu',
                child: Text(
                  'Kısa vadeli bir networking hedefi belirleyin. Spesifik ve ölçülebilir olmasına özen gösterin.',
                  style: GoogleFonts.inter(fontSize: 14, color: lightBlue),
                ),
              ),
            ],
          ),
        ),
        if (showInspirePopup)
          Positioned(
            right: 0,
            top: 0,
            child: AnimatedOpacity(
              opacity: showInspirePopup ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300, minWidth: 180, maxHeight: 100),
                margin: const EdgeInsets.only(top: 8, right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: gold, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İlham Önerisi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: mainBlue)),
                    const SizedBox(height: 4),
                    Semantics(
                      label: 'İlham önerisi popup',
                      child: Text(
                        inspireText,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
} 