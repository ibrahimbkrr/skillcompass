import 'package:freezed_annotation/freezed_annotation.dart';

part 'blockers_challenges_model.freezed.dart';
part 'blockers_challenges_model.g.dart';

@freezed
class BlockersChallengesModel with _$BlockersChallengesModel {
  const factory BlockersChallengesModel({
    required List<String> blockers,
    required List<String> challenges,
  }) = _BlockersChallengesModel;

  factory BlockersChallengesModel.fromJson(Map<String, dynamic> json) => _$BlockersChallengesModelFromJson(json);
} 