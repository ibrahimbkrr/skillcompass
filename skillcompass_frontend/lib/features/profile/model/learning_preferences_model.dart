import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_preferences_model.freezed.dart';
part 'learning_preferences_model.g.dart';

@freezed
class LearningPreferencesModel with _$LearningPreferencesModel {
  const factory LearningPreferencesModel({
    required List<String> learningStyle,
    String? customLearningStyle,
    required String onlineLearningFrequency,
    required bool mentorshipInterest,
    required List<String> learningResources,
    String? customLearningResource,
    String? learningMotivation,
    String? learningBarriers,
  }) = _LearningPreferencesModel;

  factory LearningPreferencesModel.fromJson(Map<String, dynamic> json) => _$LearningPreferencesModelFromJson(json);
} 