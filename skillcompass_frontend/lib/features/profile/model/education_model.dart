import 'package:freezed_annotation/freezed_annotation.dart';

part 'education_model.freezed.dart';
part 'education_model.g.dart';

@freezed
class EducationModel with _$EducationModel {
  const factory EducationModel({
    required String highestDegree,
    required String major,
    required bool currentlyStudent,
    required List<String> strongSubjects,
    required List<String> certificates,
  }) = _EducationModel;

  factory EducationModel.fromJson(Map<String, dynamic> json) => _$EducationModelFromJson(json);
} 