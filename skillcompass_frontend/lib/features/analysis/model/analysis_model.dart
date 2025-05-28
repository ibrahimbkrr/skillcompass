import 'package:flutter/material.dart';

class KategoriModel {
  final String ad;
  final String aciklama;
  final List<String> gucluYonler;
  final List<String> gelisimAlanlari;
  final List<String> oneriler;
  final String motivasyon;
  final String ornek;
  final List<String> kaynaklar;

  KategoriModel({
    required this.ad,
    required this.aciklama,
    required this.gucluYonler,
    required this.gelisimAlanlari,
    required this.oneriler,
    required this.motivasyon,
    required this.ornek,
    required this.kaynaklar,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) => KategoriModel(
    ad: json['ad'],
    aciklama: json['aciklama'],
    gucluYonler: List<String>.from(json['guclu_yonler'] ?? []),
    gelisimAlanlari: List<String>.from(json['gelisim_alanlari'] ?? []),
    oneriler: List<String>.from(json['oneriler'] ?? []),
    motivasyon: json['motivasyon'] ?? '',
    ornek: json['ornek'] ?? '',
    kaynaklar: List<String>.from(json['kaynaklar'] ?? []),
  );
}

class AnalizModel {
  final String ozet;
  final List<KategoriModel> kategoriler;

  AnalizModel({required this.ozet, required this.kategoriler});

  factory AnalizModel.fromJson(Map<String, dynamic> json) => AnalizModel(
    ozet: json['ozet'] ?? '',
    kategoriler: (json['kategoriler'] as List?)?.map((e) => KategoriModel.fromJson(e)).toList() ?? [],
  );
}

class CategoryMeta {
  final IconData icon;
  final Color color;
  final String badge;
  const CategoryMeta({required this.icon, required this.color, required this.badge});
}

const Map<String, CategoryMeta> CATEGORY_META = {
  'Kimlik': CategoryMeta(icon: Icons.person, color: Colors.blue, badge: 'Kimlik'),
  'Teknik Profil': CategoryMeta(icon: Icons.code, color: Colors.green, badge: 'Teknik'),
  'Öğrenme Stili': CategoryMeta(icon: Icons.school, color: Colors.orange, badge: 'Öğrenme'),
  'Kariyer Vizyonu': CategoryMeta(icon: Icons.work, color: Colors.purple, badge: 'Vizyon'),
  'Proje Deneyimleri': CategoryMeta(icon: Icons.rocket_launch, color: Colors.amber, badge: 'Proje'),
  'Networking': CategoryMeta(icon: Icons.wifi, color: Colors.indigo, badge: 'Ağ'),
  'Kişisel Marka': CategoryMeta(icon: Icons.verified_user, color: Colors.deepPurple, badge: 'Marka'),
};

CategoryMeta getCategoryMeta(String ad) => CATEGORY_META[ad] ?? CategoryMeta(icon: Icons.info, color: Colors.grey, badge: ad); 