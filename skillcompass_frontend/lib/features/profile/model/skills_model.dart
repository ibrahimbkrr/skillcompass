import 'package:freezed_annotation/freezed_annotation.dart';

part 'skills_model.freezed.dart';
part 'skills_model.g.dart';

@freezed
class SkillsModel with _$SkillsModel {
  const factory SkillsModel({
    required List<String> technicalSkills,
    required List<String> socialSkills,
    required int problemSolving,
    required String englishLevel,
    required List<String> otherLanguages,
    String? highlightedSkill,
  }) = _SkillsModel;

  factory SkillsModel.fromJson(Map<String, dynamic> json) => _$SkillsModelFromJson(json);
} 