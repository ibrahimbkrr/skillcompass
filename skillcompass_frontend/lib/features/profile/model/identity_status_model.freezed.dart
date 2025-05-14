// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IdentityStatusModel _$IdentityStatusModelFromJson(Map<String, dynamic> json) {
  return _IdentityStatusModel.fromJson(json);
}

/// @nodoc
mixin _$IdentityStatusModel {
  List<String> get developmentAreas => throw _privateConstructorUsedError;
  String? get goal1Year => throw _privateConstructorUsedError;
  int get goal5YearsLevel => throw _privateConstructorUsedError;
  String get identity => throw _privateConstructorUsedError;
  String get otherArea => throw _privateConstructorUsedError;

  /// Serializes this IdentityStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdentityStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdentityStatusModelCopyWith<IdentityStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityStatusModelCopyWith<$Res> {
  factory $IdentityStatusModelCopyWith(
          IdentityStatusModel value, $Res Function(IdentityStatusModel) then) =
      _$IdentityStatusModelCopyWithImpl<$Res, IdentityStatusModel>;
  @useResult
  $Res call(
      {List<String> developmentAreas,
      String? goal1Year,
      int goal5YearsLevel,
      String identity,
      String otherArea});
}

/// @nodoc
class _$IdentityStatusModelCopyWithImpl<$Res, $Val extends IdentityStatusModel>
    implements $IdentityStatusModelCopyWith<$Res> {
  _$IdentityStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdentityStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? developmentAreas = null,
    Object? goal1Year = freezed,
    Object? goal5YearsLevel = null,
    Object? identity = null,
    Object? otherArea = null,
  }) {
    return _then(_value.copyWith(
      developmentAreas: null == developmentAreas
          ? _value.developmentAreas
          : developmentAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      goal1Year: freezed == goal1Year
          ? _value.goal1Year
          : goal1Year // ignore: cast_nullable_to_non_nullable
              as String?,
      goal5YearsLevel: null == goal5YearsLevel
          ? _value.goal5YearsLevel
          : goal5YearsLevel // ignore: cast_nullable_to_non_nullable
              as int,
      identity: null == identity
          ? _value.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as String,
      otherArea: null == otherArea
          ? _value.otherArea
          : otherArea // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdentityStatusModelImplCopyWith<$Res>
    implements $IdentityStatusModelCopyWith<$Res> {
  factory _$$IdentityStatusModelImplCopyWith(_$IdentityStatusModelImpl value,
          $Res Function(_$IdentityStatusModelImpl) then) =
      __$$IdentityStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> developmentAreas,
      String? goal1Year,
      int goal5YearsLevel,
      String identity,
      String otherArea});
}

/// @nodoc
class __$$IdentityStatusModelImplCopyWithImpl<$Res>
    extends _$IdentityStatusModelCopyWithImpl<$Res, _$IdentityStatusModelImpl>
    implements _$$IdentityStatusModelImplCopyWith<$Res> {
  __$$IdentityStatusModelImplCopyWithImpl(_$IdentityStatusModelImpl _value,
      $Res Function(_$IdentityStatusModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of IdentityStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? developmentAreas = null,
    Object? goal1Year = freezed,
    Object? goal5YearsLevel = null,
    Object? identity = null,
    Object? otherArea = null,
  }) {
    return _then(_$IdentityStatusModelImpl(
      developmentAreas: null == developmentAreas
          ? _value._developmentAreas
          : developmentAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      goal1Year: freezed == goal1Year
          ? _value.goal1Year
          : goal1Year // ignore: cast_nullable_to_non_nullable
              as String?,
      goal5YearsLevel: null == goal5YearsLevel
          ? _value.goal5YearsLevel
          : goal5YearsLevel // ignore: cast_nullable_to_non_nullable
              as int,
      identity: null == identity
          ? _value.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as String,
      otherArea: null == otherArea
          ? _value.otherArea
          : otherArea // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityStatusModelImpl implements _IdentityStatusModel {
  const _$IdentityStatusModelImpl(
      {final List<String> developmentAreas = const [],
      this.goal1Year,
      required this.goal5YearsLevel,
      this.identity = '',
      this.otherArea = ''})
      : _developmentAreas = developmentAreas;

  factory _$IdentityStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityStatusModelImplFromJson(json);

  final List<String> _developmentAreas;
  @override
  @JsonKey()
  List<String> get developmentAreas {
    if (_developmentAreas is EqualUnmodifiableListView)
      return _developmentAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_developmentAreas);
  }

  @override
  final String? goal1Year;
  @override
  final int goal5YearsLevel;
  @override
  @JsonKey()
  final String identity;
  @override
  @JsonKey()
  final String otherArea;

  @override
  String toString() {
    return 'IdentityStatusModel(developmentAreas: $developmentAreas, goal1Year: $goal1Year, goal5YearsLevel: $goal5YearsLevel, identity: $identity, otherArea: $otherArea)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityStatusModelImpl &&
            const DeepCollectionEquality()
                .equals(other._developmentAreas, _developmentAreas) &&
            (identical(other.goal1Year, goal1Year) ||
                other.goal1Year == goal1Year) &&
            (identical(other.goal5YearsLevel, goal5YearsLevel) ||
                other.goal5YearsLevel == goal5YearsLevel) &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.otherArea, otherArea) ||
                other.otherArea == otherArea));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_developmentAreas),
      goal1Year,
      goal5YearsLevel,
      identity,
      otherArea);

  /// Create a copy of IdentityStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityStatusModelImplCopyWith<_$IdentityStatusModelImpl> get copyWith =>
      __$$IdentityStatusModelImplCopyWithImpl<_$IdentityStatusModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityStatusModelImplToJson(
      this,
    );
  }
}

abstract class _IdentityStatusModel implements IdentityStatusModel {
  const factory _IdentityStatusModel(
      {final List<String> developmentAreas,
      final String? goal1Year,
      required final int goal5YearsLevel,
      final String identity,
      final String otherArea}) = _$IdentityStatusModelImpl;

  factory _IdentityStatusModel.fromJson(Map<String, dynamic> json) =
      _$IdentityStatusModelImpl.fromJson;

  @override
  List<String> get developmentAreas;
  @override
  String? get goal1Year;
  @override
  int get goal5YearsLevel;
  @override
  String get identity;
  @override
  String get otherArea;

  /// Create a copy of IdentityStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdentityStatusModelImplCopyWith<_$IdentityStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
