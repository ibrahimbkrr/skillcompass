import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_community_model.freezed.dart';
part 'support_community_model.g.dart';

@freezed
class SupportCommunityModel with _$SupportCommunityModel {
  const factory SupportCommunityModel({
    required List<String> communities,
    required List<String> mentors,
  }) = _SupportCommunityModel;

  factory SupportCommunityModel.fromJson(Map<String, dynamic> json) => _$SupportCommunityModelFromJson(json);
} 