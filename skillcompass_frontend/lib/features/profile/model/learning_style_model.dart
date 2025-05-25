import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_style_model.freezed.dart';
part 'learning_style_model.g.dart';

@freezed
class LearningStyleModel with _$LearningStyleModel {
  const factory LearningStyleModel({
    required String preference,
    required String customPreference,
    required List<String> resources,
    required String customResource,
    required String motivation,
    required String barriers,
  }) = _LearningStyleModel;

  factory LearningStyleModel.fromJson(Map<String, dynamic> json) => _$LearningStyleModelFromJson(json);
} 