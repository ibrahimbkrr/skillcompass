// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityStatusModelImpl _$$IdentityStatusModelImplFromJson(
        Map<String, dynamic> json) =>
    _$IdentityStatusModelImpl(
      developmentAreas: (json['developmentAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      goal1Year: json['goal1Year'] as String?,
      goal5YearsLevel: (json['goal5YearsLevel'] as num).toInt(),
      identity: json['identity'] as String? ?? '',
      otherArea: json['otherArea'] as String? ?? '',
    );

Map<String, dynamic> _$$IdentityStatusModelImplToJson(
        _$IdentityStatusModelImpl instance) =>
    <String, dynamic>{
      'developmentAreas': instance.developmentAreas,
      'goal1Year': instance.goal1Year,
      'goal5YearsLevel': instance.goal5YearsLevel,
      'identity': instance.identity,
      'otherArea': instance.otherArea,
    };
