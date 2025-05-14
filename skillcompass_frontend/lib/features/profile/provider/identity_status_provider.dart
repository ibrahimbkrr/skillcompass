import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/identity_status_model.dart';

class IdentityStatusNotifier extends StateNotifier<IdentityStatusModel> {
  IdentityStatusNotifier() : super(const IdentityStatusModel(goal5YearsLevel: 1));

  void setIdentity(String value) => state = state.copyWith(identity: value);
  void setDevelopmentAreas(List<String> value) => state = state.copyWith(developmentAreas: value);
  void setOtherArea(String value) => state = state.copyWith(otherArea: value);
  void setGoal1Year(String? value) => state = state.copyWith(goal1Year: value);
  void setGoal5YearsLevel(int value) => state = state.copyWith(goal5YearsLevel: value);
}

final identityStatusProvider = StateNotifierProvider<IdentityStatusNotifier, IdentityStatusModel>(
  (ref) => IdentityStatusNotifier(),
); 