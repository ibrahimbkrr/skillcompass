import 'package:freezed_annotation/freezed_annotation.dart';

part 'consents_model.freezed.dart';
part 'consents_model.g.dart';

@freezed
class ConsentsModel with _$ConsentsModel {
  const factory ConsentsModel({
    required bool dataProcessingConsent,
    required bool aiCareerAdviceConsent,
  }) = _ConsentsModel;

  factory ConsentsModel.fromJson(Map<String, dynamic> json) => _$ConsentsModelFromJson(json);
} 