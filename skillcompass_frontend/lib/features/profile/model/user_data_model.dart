import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_model.dart';
import 'education_model.dart';
import 'work_experience_model.dart';
import 'skills_model.dart';
import 'interests_and_goals_model.dart';
import 'working_style_and_motivation_model.dart';
import 'self_assessment_model.dart';
import 'learning_preferences_model.dart';
import 'consents_model.dart';

part 'user_data_model.freezed.dart';
part 'user_data_model.g.dart';

@freezed
class UserDataModel with _$UserDataModel {
  const factory UserDataModel({
    required String firstName,
    required String lastName,
    required String email,
    required String uid,
    required int birthYear,
    String? gender,
    required LocationModel location,
    required EducationModel education,
    required WorkExperienceModel workExperience,
    required SkillsModel skills,
    required InterestsAndGoalsModel interestsAndGoals,
    required WorkingStyleAndMotivationModel workingStyleAndMotivation,
    required SelfAssessmentModel selfAssessment,
    required LearningPreferencesModel learningPreferences,
    required ConsentsModel consents,
    String? createdAt,
  }) = _UserDataModel;

  factory UserDataModel.fromJson(Map<String, dynamic> json) => _$UserDataModelFromJson(json);
} 