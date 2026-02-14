// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettingsState {
  Locale get locale => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get cityName => throw _privateConstructorUsedError;
  String get calculationMethod => throw _privateConstructorUsedError;
  String get madhab => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {Locale locale,
      double? latitude,
      double? longitude,
      String? cityName,
      String calculationMethod,
      String madhab});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? cityName = freezed,
    Object? calculationMethod = null,
    Object? madhab = null,
  }) {
    return _then(_value.copyWith(
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      cityName: freezed == cityName
          ? _value.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String?,
      calculationMethod: null == calculationMethod
          ? _value.calculationMethod
          : calculationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      madhab: null == madhab
          ? _value.madhab
          : madhab // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Locale locale,
      double? latitude,
      double? longitude,
      String? cityName,
      String calculationMethod,
      String madhab});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? cityName = freezed,
    Object? calculationMethod = null,
    Object? madhab = null,
  }) {
    return _then(_$SettingsStateImpl(
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      cityName: freezed == cityName
          ? _value.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String?,
      calculationMethod: null == calculationMethod
          ? _value.calculationMethod
          : calculationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      madhab: null == madhab
          ? _value.madhab
          : madhab // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {required this.locale,
      this.latitude,
      this.longitude,
      this.cityName,
      this.calculationMethod = 'muslim_league',
      this.madhab = 'shafi'});

  @override
  final Locale locale;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? cityName;
  @override
  @JsonKey()
  final String calculationMethod;
  @override
  @JsonKey()
  final String madhab;

  @override
  String toString() {
    return 'SettingsState(locale: $locale, latitude: $latitude, longitude: $longitude, cityName: $cityName, calculationMethod: $calculationMethod, madhab: $madhab)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName) &&
            (identical(other.calculationMethod, calculationMethod) ||
                other.calculationMethod == calculationMethod) &&
            (identical(other.madhab, madhab) || other.madhab == madhab));
  }

  @override
  int get hashCode => Object.hash(runtimeType, locale, latitude, longitude,
      cityName, calculationMethod, madhab);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {required final Locale locale,
      final double? latitude,
      final double? longitude,
      final String? cityName,
      final String calculationMethod,
      final String madhab}) = _$SettingsStateImpl;

  @override
  Locale get locale;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get cityName;
  @override
  String get calculationMethod;
  @override
  String get madhab;
  @override
  @JsonKey(ignore: true)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
