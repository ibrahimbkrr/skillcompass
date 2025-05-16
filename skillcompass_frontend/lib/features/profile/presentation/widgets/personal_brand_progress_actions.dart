import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalBrandProgressActions extends StatelessWidget {
  final bool isComplete;
  final VoidCallback? onSave;
  final bool isSaving;
  final String? summary;
  final List<Map<String, String>>? resources;
  final int totalSteps;
  final int completedSteps;
  const PersonalBrandProgressActions({
    Key? key,
    required this.isComplete,
    this.onSave,
    this.isSaving = false,
    this.summary,
    this.resources,
    this.totalSteps = 4,
    this.completedSteps = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainBlue = const Color(0xFF2A4B7C);
    final gold = const Color(0xFFFFC700);
    final accentCoral = const Color(0xFFFF6B6B);
    final cloudGrey = const Color(0xFFA0AEC0);
    final lightBlue = const Color(0xFF6B7280);
    final darkGrey = const Color(0xFF4A4A4A);
    final accentBlue = const Color(0xFF3D5AFE);
    final successGreen = const Color(0xFF38A169);

    final double progress = (totalSteps > 0) ? (completedSteps / totalSteps).clamp(0.0, 1.0) : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // İlerleme Çubuğu
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            return Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: cloudGrey.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 12,
                        width: barWidth * progress,
                        decoration: BoxDecoration(
                          color: mainBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mainBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.campaign, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text('$completedSteps/$totalSteps', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        // Özet Paneli
        if (isComplete && summary != null)
          AnimatedOpacity(
            opacity: isComplete ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: gold, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marka Stratejiniz', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: mainBlue)),
                  const SizedBox(height: 6),
                  Text(
                    summary!,
                    style: GoogleFonts.inter(fontSize: 14, color: darkGrey),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        // Kaynaklar Bölümü
        if (isComplete && resources != null && resources!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: gold, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gold.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Markanızı Güçlendirin', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: mainBlue)),
                const SizedBox(height: 6),
                ...resources!.map((res) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () => _launchUrl(context, res['url'] ?? ''),
                    child: Text(
                      res['title'] ?? '',
                      style: GoogleFonts.inter(fontSize: 14, color: lightBlue, decoration: TextDecoration.underline),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
              ],
            ),
          ),
        // Kaydet ve İlerle Butonu
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: 52,
          margin: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton(
            onPressed: isComplete && !isSaving ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete ? accentCoral : cloudGrey,
              foregroundColor: isComplete ? Colors.white : darkGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Kaydet ve İlerle'),
          ),
        ),
        const SizedBox(height: 8),
        // Açıklama
        Semantics(
          label: 'Kart tamamlama ipucu',
          child: Text(
            'Kişisel markanızı tanımlayarak profesyonel görünürlüğünüzü artırın.',
            style: GoogleFonts.inter(fontSize: 14, color: lightBlue),
            textAlign: TextAlign.center,
          ),
        ),
        // Geri Butonu
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: lightBlue, size: 24, semanticLabel: 'Geri'),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Geri',
          ),
        ),
      ],
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    // url_launcher veya benzeri bir paketle açılabilir.
    // Burada sadece placeholder olarak ScaffoldMessenger ile bilgi veriliyor.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bağlantı: $url'), duration: const Duration(seconds: 2)),
    );
  }
} 