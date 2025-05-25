import 'package:freezed_annotation/freezed_annotation.dart';

part 'technical_profile_model.freezed.dart';
part 'technical_profile_model.g.dart';

@freezed
class TechnicalProfileModel with _$TechnicalProfileModel {
  const factory TechnicalProfileModel({
    required List<String> skills,
    required String highlightSkill,
    required String learningApproach,
    required int confidence,
  }) = _TechnicalProfileModel;

  factory TechnicalProfileModel.fromJson(Map<String, dynamic> json) => _$TechnicalProfileModelFromJson(json);
} 