import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity_status_model.freezed.dart';
part 'identity_status_model.g.dart';

@freezed
class IdentityStatusModel with _$IdentityStatusModel {
  const factory IdentityStatusModel({
    @Default([]) List<String> developmentAreas,
    String? goal1Year,
    required int goal5YearsLevel,
    @Default('') String identity,
    @Default('') String otherArea,
  }) = _IdentityStatusModel;

  factory IdentityStatusModel.fromJson(Map<String, dynamic> json) =>
      _$IdentityStatusModelFromJson(json);
}