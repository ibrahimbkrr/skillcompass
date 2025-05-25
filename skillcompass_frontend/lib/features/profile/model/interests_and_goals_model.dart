import 'package:freezed_annotation/freezed_annotation.dart';

part 'interests_and_goals_model.freezed.dart';
part 'interests_and_goals_model.g.dart';

@freezed
class InterestsAndGoalsModel with _$InterestsAndGoalsModel {
  const factory InterestsAndGoalsModel({
    required List<String> interestedSectors,
    required List<String> interestedRoles,
    required String careerGoal1Year,
    required String careerGoal5Year,
    required bool entrepreneurshipInterest,
    required bool startupCultureInterest,
    required bool internationalCareerGoal,
    String? desiredImpactArea,
    int? careerGoalsClarity,
    List<String>? careerPriorities,
    String? customCareerPriority,
    int? careerProgress,
  }) = _InterestsAndGoalsModel;

  factory InterestsAndGoalsModel.fromJson(Map<String, dynamic> json) => _$InterestsAndGoalsModelFromJson(json);
} 