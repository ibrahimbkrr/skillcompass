import 'package:freezed_annotation/freezed_annotation.dart';

part 'working_style_and_motivation_model.freezed.dart';
part 'working_style_and_motivation_model.g.dart';

@freezed
class WorkingStyleAndMotivationModel with _$WorkingStyleAndMotivationModel {
  const factory WorkingStyleAndMotivationModel({
    required String workPreference,
    required String workingLocationPreference,
    required String workingHoursPreference,
    required String preferredCompanySize,
    required String projectTypePreference,
    required List<String> mainMotivation,
    String? customMotivation,
  }) = _WorkingStyleAndMotivationModel;

  factory WorkingStyleAndMotivationModel.fromJson(Map<String, dynamic> json) => _$WorkingStyleAndMotivationModelFromJson(json);
} 