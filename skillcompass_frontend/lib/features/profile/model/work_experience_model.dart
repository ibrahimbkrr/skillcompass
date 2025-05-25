import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_experience_model.freezed.dart';
part 'work_experience_model.g.dart';

@freezed
class WorkExperienceModel with _$WorkExperienceModel {
  const factory WorkExperienceModel({
    required bool currentlyWorking,
    required String yearsExperience,
    required List<String> sectorsWorked,
    required List<String> positions,
    required bool managerialExperience,
    required bool freelanceExperience,
  }) = _WorkExperienceModel;

  factory WorkExperienceModel.fromJson(Map<String, dynamic> json) => _$WorkExperienceModelFromJson(json);
} 