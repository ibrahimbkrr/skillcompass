import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityStoryCard extends StatelessWidget {
  final TextEditingController storyController;
  final bool showInspire;
  final String? inspireText;
  final VoidCallback onInspireTap;
  final Function(String) onChanged;
  const IdentityStoryCard({
    super.key,
    required this.storyController,
    required this.showInspire,
    required this.inspireText,
    required this.onInspireTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Kendinizi bir cümleyle nasıl anlatırsınız?',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onInspireTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: storyController,
          maxLength: 100,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Örneğin: Kullanıcı odaklı mobil uygulamalar geliştiren bir Flutter tutkunu.',
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
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          autofocus: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) => v == null || v.trim().length < 10 ? 'Lütfen kendinizi tarif edin.' : null,
        ),
        if (showInspire && inspireText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AnimatedOpacity(
              opacity: showInspire ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(inspireText!, style: GoogleFonts.inter(fontSize: 14)),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text('Unvanınızdan ziyade tutkunuzu ve vizyonunuzu düşünün. Sizi ne tanımlar?',
          style: GoogleFonts.inter(fontSize: 14)),
      ],
    );
  }
} 