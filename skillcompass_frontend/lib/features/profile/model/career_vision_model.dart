import 'package:freezed_annotation/freezed_annotation.dart';

part 'career_vision_model.freezed.dart';
part 'career_vision_model.g.dart';

@freezed
class CareerVisionModel with _$CareerVisionModel {
  const factory CareerVisionModel({
    required String shortTermGoal,
    required String longTermGoal,
    required List<String> priorities,
    required String customPriority,
    required int progress,
  }) = _CareerVisionModel;

  factory CareerVisionModel.fromJson(Map<String, dynamic> json) => _$CareerVisionModelFromJson(json);
} 