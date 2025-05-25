import 'package:freezed_annotation/freezed_annotation.dart';

part 'self_assessment_model.freezed.dart';
part 'self_assessment_model.g.dart';

@freezed
class SelfAssessmentModel with _$SelfAssessmentModel {
  const factory SelfAssessmentModel({
    required List<String> strengths,
    required List<String> weaknesses,
    required String lifeChallenges,
    required String stressHandling,
    required int learningDesire,
    String? identityStory,
    int? technicalConfidence,
  }) = _SelfAssessmentModel;

  factory SelfAssessmentModel.fromJson(Map<String, dynamic> json) => _$SelfAssessmentModelFromJson(json);
} 