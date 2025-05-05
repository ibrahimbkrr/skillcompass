import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp vb. için gerekebilir

// Analiz sonuçlarını ve özet profil bilgilerini gösteren ekran
class AnalysisReportScreen extends StatefulWidget {
  // Dashboard'dan gönderilecek veriler
  final Map<String, dynamic> profileData;
  final Map<String, dynamic> analysisResult; // Simüle edilmiş analiz sonucu

  // Constructor: Gerekli parametreleri alır
  const AnalysisReportScreen({
    super.key,
    required this.profileData,
    required this.analysisResult,
  });

  @override
  State<AnalysisReportScreen> createState() => _AnalysisReportScreenState();
}

class _AnalysisReportScreenState extends State<AnalysisReportScreen> {
  // --- Veri Erişim Yardımcı Fonksiyonları ---

  // Belirli bir bölümden belirli bir alanı güvenli şekilde alır
  dynamic _getData(String sectionKey, String fieldKey) {
    // Önce bölümün var olup olmadığını ve Map olup olmadığını kontrol et
    if (widget.profileData.containsKey(sectionKey) &&
        widget.profileData[sectionKey] is Map) {
      // Sonra alanın var olup olmadığını kontrol et
      return widget.profileData[sectionKey]?[fieldKey];
    }
    return null; // Bölüm veya alan yoksa null döndür
  }

  // Belirli bir bölümden belirli bir listeyi (String) güvenli şekilde alır
  List<String> _getListData(String sectionKey, String fieldKey) {
    var data = _getData(sectionKey, fieldKey); // Önce veriyi al
    if (data is List) {
      // Listeyi filtreleyerek sadece String olanları ve boş olmayanları alalım
      return List<String>.from(
        data.whereType<String>().where((s) => s.isNotEmpty),
      );
    }
    return []; // Liste değilse veya boşsa boş liste döndür
  }

  // Belirli bir bölümden belirli bir Map listesini (örn: userSkills) güvenli şekilde alır
  List<Map<String, dynamic>> _getMapListData(
    String sectionKey,
    String fieldKey,
  ) {
    var data = _getData(sectionKey, fieldKey); // Önce veriyi al
    if (data is List) {
      // Listeyi filtreleyerek sadece Map<String, dynamic> olanları alalım
      return List<Map<String, dynamic>>.from(
        data.whereType<Map<String, dynamic>>(),
      );
    }
    return []; // Liste değilse veya boşsa boş liste döndür
  }
  // -----------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- Verilerden özet bilgiler çıkaralım (Null kontrolleri ile) ---
    String currentStatus =
        _getData('identity', 'currentStatus') ?? 'Belirtilmemiş';
    String academicStage =
        _getData('identity', 'academicStage') ?? 'Belirtilmemiş';
    List<Map<String, dynamic>> userSkills = _getMapListData(
      'technical',
      'userSkills',
    );
    List<String> advancedSkills =
        userSkills
            .where((s) => s['level'] == 'Advanced')
            .map((s) => s['skill'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
    String learningStyle =
        _getData('learning', 'learningStyle') ?? 'Belirtilmemiş';
    String oneYearTheme =
        _getData('vision', 'oneYearGoalTheme') ?? 'Belirtilmemiş';
    List<String> targetRoles = _getListData('vision', 'targetTechnicalRoles');
    List<String> blockers = _getListData('blockers', 'progressionBlockers');

    // Simüle Edilmiş Analiz Sonucu
    String summary =
        widget.analysisResult['summary'] ?? 'Analiz özeti oluşturulamadı.';
    List<String> strengths = List<String>.from(
      widget.analysisResult['strengths'] ?? [],
    );
    List<String> improvements = List<String>.from(
      widget.analysisResult['areasForImprovement'] ?? [],
    );
    // -----------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Raporu ve Yol Haritası'),
        elevation: 1,
      ),
      body: ListView(
        // Çok içerik olabileceği için ListView daha uygun
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Analiz Özeti Bölümü ---
          _buildSectionTitle(context, Icons.insights_rounded, "Analiz Özeti"),
          Card(
            // Özeti kart içine alalım
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                summary,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ), // Satır aralığı
            ),
          ),
          const SizedBox(height: 24),

          // --- Güçlü Yönler ---
          if (strengths.isNotEmpty) ...[
            _buildSectionTitle(
              context,
              Icons.star_rounded,
              "Öne Çıkan Güçlü Yönlerin",
            ),
            _buildChipList(
              context,
              strengths,
              Colors.green.shade600,
            ), // Daha canlı renk
            const SizedBox(height: 24),
          ],

          // --- Gelişim Alanları ---
          if (improvements.isNotEmpty) ...[
            _buildSectionTitle(
              context,
              Icons.trending_up_rounded,
              "Odaklanabileceğin Gelişim Alanları",
            ),
            _buildChipList(
              context,
              improvements,
              Colors.orange.shade700,
            ), // Daha canlı renk
            const SizedBox(height: 24),
          ],

          const Divider(height: 30, thickness: 1),

          // --- Profil Özeti Bölümü ---
          _buildSectionTitle(
            context,
            Icons.summarize_rounded,
            "Profilinden Önemli Notlar",
          ),
          _buildInfoRow("Mevcut Durumun", currentStatus),
          _buildInfoRow("Akademik Seviyen", academicStage),
          if (advancedSkills.isNotEmpty)
            _buildInfoRow(
              "İleri Seviye Becerilerin",
              advancedSkills.join(', '),
            ),
          _buildInfoRow("Öğrenme Tarzın", learningStyle),
          _buildInfoRow("1 Yıllık Hedef Teman", oneYearTheme),
          if (targetRoles.isNotEmpty)
            _buildInfoRow(
              "Hedeflediğin Roller",
              targetRoles.take(3).join(', ') +
                  (targetRoles.length > 3 ? "..." : ""),
            ),
          if (blockers.isNotEmpty)
            _buildInfoRow(
              "Belirttiğin Engeller",
              blockers.take(2).join(', ') + (blockers.length > 2 ? "..." : ""),
            ),
          const SizedBox(height: 30),

          // --- Son Not ---
          Container(
            // Notu biraz vurgulayalım
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "Bu özet, profilini temel alarak oluşturulmuştur.\nDetaylı yol haritan ve kişiselleştirilmiş önerilerin için analiz süreci devam ediyor.", // Mesaj güncellendi
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey[700],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Düzeltilmiş Yardımcı Widget: Bölüm Başlığı ---
  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Boşluk artırıldı
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.secondary,
          ), // İkon rengi ve boyutu
          const SizedBox(width: 10),
          Expanded(
            // Başlığın taşmasını engelle
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ), // Font boyutu
            ),
          ),
        ],
      ),
    );
  }
  // --------------------------------------------------

  // --- Düzeltilmiş Yardımcı Widget: Bilgi Satırı ---
  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    // Değer boş veya belirtilmemişse gösterme
    if (value.isEmpty || value == 'Belirtilmemiş')
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Dikey boşluk
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "▪ $label: ",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ), // Başında madde işareti
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
  // --------------------------------------------------

  // --- Düzeltilmiş Yardımcı Widget: Chip Listesi ---
  Widget _buildChipList(
    BuildContext context,
    List<String> items,
    Color chipColor,
  ) {
    final theme = Theme.of(context);
    // Liste boşsa gösterme
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      // Chip listesine biraz padding ekleyelim
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 6.0, // Dikey boşluk
        children:
            items
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: chipColor.withOpacity(
                      0.12,
                    ), // Daha hafif arka plan
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ), // Daha okunaklı renk
                    side: BorderSide(
                      color: chipColor.withOpacity(0.4),
                    ), // Daha belirgin kenarlık
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ), // İç boşluk
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ), // Daha yuvarlak chip
                  ),
                )
                .toList(),
      ),
    );
  }

  // --------------------------------------------------
}
