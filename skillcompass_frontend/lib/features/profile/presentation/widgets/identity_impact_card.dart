import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityImpactCard extends StatelessWidget {
  final List<String> impactOptions;
  final Map<String, IconData> impactIcons;
  final String? selectedImpact;
  final Function(String?) onChanged;
  const IdentityImpactCard({
    super.key,
    required this.impactOptions,
    required this.impactIcons,
    required this.selectedImpact,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('En büyük etkinizi nerede yaratıyorsunuz?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedImpact,
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('Seçiniz', maxLines: 1, overflow: TextOverflow.ellipsis)),
            ...impactOptions.map((e) => DropdownMenuItem<String>(
              value: e,
              child: Row(
                children: [
                  Icon(impactIcons[e], color: Theme.of(context).primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) => v == null ? 'Lütfen bir etki alanı seçin.' : null,
        ),
        const SizedBox(height: 6),
        Text('Şu anda veya gelecekte en çok katkı sağladığınız alanı seçin.',
          style: GoogleFonts.inter(fontSize: 14)),
      ],
    );
  }
} 