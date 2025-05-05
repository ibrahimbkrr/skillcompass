import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Artık doğrudan Firestore işlemi yapmıyoruz
// import 'package:intl/intl.dart'; // Tarih formatlama için şimdilik gerek yok

// Analiz metnini gösteren ekran
class AnalysisReportScreen extends StatelessWidget {
  // StatelessWidget yeterli
  // Dashboard'dan gönderilecek analiz metni
  final String analysisReportText;

  // Constructor: Gerekli parametreyi alır
  const AnalysisReportScreen({super.key, required this.analysisReportText});

  // --- Yardımcı Widget: Bölüm Başlığı ---
  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12.0,
        top: 16.0,
      ), // Üstüne de boşluk
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ), // Boyut ayarlandı
            ),
          ),
        ],
      ),
    );
  }
  // --------------------------------------------------

  // --- Yardımcı Widget: Chip Listesi ---
  // Bu fonksiyon şu an doğrudan kullanılmıyor ama ileride yapısal veri gelirse diye durabilir.
  Widget _buildChipList(
    BuildContext context,
    List<String> items,
    Color chipColor,
  ) {
    final theme = Theme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 6.0,
        children:
            items
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: chipColor.withOpacity(0.15),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    side: BorderSide(color: chipColor.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Raporu ve Yol Haritası'),
        elevation: 1,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Metin uzun olabilir
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              Icons.insights_rounded,
              "Kariyer Analiz Raporun",
            ),
            const SizedBox(height: 8),
            // Gelen analiz metnini göster
            Container(
              // Metni bir kutu içine alalım
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100], // Hafif bir arka plan
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                // Kullanıcının metni kopyalayabilmesi için
                analysisReportText.isEmpty
                    ? "Analiz raporu alınamadı veya boş."
                    : analysisReportText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 15,
                ), // Okunabilirlik
              ),
            ),
            const SizedBox(height: 30),

            // --- Son Not ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Bu rapor, sağladığınız bilgilere dayanarak yapay zeka tarafından oluşturulmuştur.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
