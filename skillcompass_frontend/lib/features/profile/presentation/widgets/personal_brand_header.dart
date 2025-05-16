import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalBrandHeader extends StatelessWidget {
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final VoidCallback? onGuide;
  const PersonalBrandHeader({
    super.key,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    this.onGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Kişisel marka simgesi',
              container: true,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mainBlue, gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Kişisel marka başlığı',
                    child: Text(
                      'Kişisel Markanızı İnşa Edin',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: mainBlue,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Kişisel marka açıklaması',
                    child: Text(
                      'Bilişim dünyasında nasıl öne çıkıyorsunuz? Çevrimiçi varlığınızı tanımlayın, kişisel markanızı güçlendirin ve iş fırsatlarını artırın.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: cloudGrey,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Rehber',
              button: true,
              child: IconButton(
                icon: Icon(Icons.info_outline_rounded, color: gold, size: 28),
                onPressed: onGuide ?? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => _PersonalBrandGuideDialog(mainBlue: mainBlue),
                  );
                },
                tooltip: 'Kişisel Marka Rehberi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Kendinizi dünyaya tanıtın, markanızla fark yaratın!',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: mainBlue,
          ),
        ),
      ],
    );
  }
}

class _PersonalBrandGuideDialog extends StatelessWidget {
  final Color mainBlue;
  const _PersonalBrandGuideDialog({required this.mainBlue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kişisel Marka Kartı',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: mainBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu kart, çevrimiçi varlığınızı ve kişisel marka hedeflerinizi tanımlamanıza yardımcı olur. Profillerinizi optimize edin, içerik stratejinizi planlayın ve profesyonel görünürlüğünüzü artırın.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'İpucu: Düzenli paylaşım ve özgün içerik, markanızı güçlendirir.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 