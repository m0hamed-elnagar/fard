// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 Locale get locale; double? get latitude; double? get longitude; String? get cityName; String get calculationMethod; String get madhab; String get morningAzkarTime; String get eveningAzkarTime; List<AzkarReminder> get reminders; List<SalaahSettings> get salaahSettings; bool get isAzanVoiceDownloading;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.calculationMethod, calculationMethod) || other.calculationMethod == calculationMethod)&&(identical(other.madhab, madhab) || other.madhab == madhab)&&(identical(other.morningAzkarTime, morningAzkarTime) || other.morningAzkarTime == morningAzkarTime)&&(identical(other.eveningAzkarTime, eveningAzkarTime) || other.eveningAzkarTime == eveningAzkarTime)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&const DeepCollectionEquality().equals(other.salaahSettings, salaahSettings)&&(identical(other.isAzanVoiceDownloading, isAzanVoiceDownloading) || other.isAzanVoiceDownloading == isAzanVoiceDownloading));
}


@override
int get hashCode => Object.hash(runtimeType,locale,latitude,longitude,cityName,calculationMethod,madhab,morningAzkarTime,eveningAzkarTime,const DeepCollectionEquality().hash(reminders),const DeepCollectionEquality().hash(salaahSettings),isAzanVoiceDownloading);

@override
String toString() {
  return 'SettingsState(locale: $locale, latitude: $latitude, longitude: $longitude, cityName: $cityName, calculationMethod: $calculationMethod, madhab: $madhab, morningAzkarTime: $morningAzkarTime, eveningAzkarTime: $eveningAzkarTime, reminders: $reminders, salaahSettings: $salaahSettings, isAzanVoiceDownloading: $isAzanVoiceDownloading)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 Locale locale, double? latitude, double? longitude, String? cityName, String calculationMethod, String madhab, String morningAzkarTime, String eveningAzkarTime, List<AzkarReminder> reminders, List<SalaahSettings> salaahSettings, bool isAzanVoiceDownloading
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? latitude = freezed,Object? longitude = freezed,Object? cityName = freezed,Object? calculationMethod = null,Object? madhab = null,Object? morningAzkarTime = null,Object? eveningAzkarTime = null,Object? reminders = null,Object? salaahSettings = null,Object? isAzanVoiceDownloading = null,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as Locale,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,calculationMethod: null == calculationMethod ? _self.calculationMethod : calculationMethod // ignore: cast_nullable_to_non_nullable
as String,madhab: null == madhab ? _self.madhab : madhab // ignore: cast_nullable_to_non_nullable
as String,morningAzkarTime: null == morningAzkarTime ? _self.morningAzkarTime : morningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,eveningAzkarTime: null == eveningAzkarTime ? _self.eveningAzkarTime : eveningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<AzkarReminder>,salaahSettings: null == salaahSettings ? _self.salaahSettings : salaahSettings // ignore: cast_nullable_to_non_nullable
as List<SalaahSettings>,isAzanVoiceDownloading: null == isAzanVoiceDownloading ? _self.isAzanVoiceDownloading : isAzanVoiceDownloading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Locale locale,  double? latitude,  double? longitude,  String? cityName,  String calculationMethod,  String madhab,  String morningAzkarTime,  String eveningAzkarTime,  List<AzkarReminder> reminders,  List<SalaahSettings> salaahSettings,  bool isAzanVoiceDownloading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.locale,_that.latitude,_that.longitude,_that.cityName,_that.calculationMethod,_that.madhab,_that.morningAzkarTime,_that.eveningAzkarTime,_that.reminders,_that.salaahSettings,_that.isAzanVoiceDownloading);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Locale locale,  double? latitude,  double? longitude,  String? cityName,  String calculationMethod,  String madhab,  String morningAzkarTime,  String eveningAzkarTime,  List<AzkarReminder> reminders,  List<SalaahSettings> salaahSettings,  bool isAzanVoiceDownloading)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.locale,_that.latitude,_that.longitude,_that.cityName,_that.calculationMethod,_that.madhab,_that.morningAzkarTime,_that.eveningAzkarTime,_that.reminders,_that.salaahSettings,_that.isAzanVoiceDownloading);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Locale locale,  double? latitude,  double? longitude,  String? cityName,  String calculationMethod,  String madhab,  String morningAzkarTime,  String eveningAzkarTime,  List<AzkarReminder> reminders,  List<SalaahSettings> salaahSettings,  bool isAzanVoiceDownloading)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.locale,_that.latitude,_that.longitude,_that.cityName,_that.calculationMethod,_that.madhab,_that.morningAzkarTime,_that.eveningAzkarTime,_that.reminders,_that.salaahSettings,_that.isAzanVoiceDownloading);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({required this.locale, this.latitude, this.longitude, this.cityName, this.calculationMethod = 'muslim_league', this.madhab = 'shafi', this.morningAzkarTime = '05:00', this.eveningAzkarTime = '18:00', final  List<AzkarReminder> reminders = const [], final  List<SalaahSettings> salaahSettings = const [], this.isAzanVoiceDownloading = false}): _reminders = reminders,_salaahSettings = salaahSettings;
  

@override final  Locale locale;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? cityName;
@override@JsonKey() final  String calculationMethod;
@override@JsonKey() final  String madhab;
@override@JsonKey() final  String morningAzkarTime;
@override@JsonKey() final  String eveningAzkarTime;
 final  List<AzkarReminder> _reminders;
@override@JsonKey() List<AzkarReminder> get reminders {
  if (_reminders is EqualUnmodifiableListView) return _reminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminders);
}

 final  List<SalaahSettings> _salaahSettings;
@override@JsonKey() List<SalaahSettings> get salaahSettings {
  if (_salaahSettings is EqualUnmodifiableListView) return _salaahSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_salaahSettings);
}

@override@JsonKey() final  bool isAzanVoiceDownloading;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.calculationMethod, calculationMethod) || other.calculationMethod == calculationMethod)&&(identical(other.madhab, madhab) || other.madhab == madhab)&&(identical(other.morningAzkarTime, morningAzkarTime) || other.morningAzkarTime == morningAzkarTime)&&(identical(other.eveningAzkarTime, eveningAzkarTime) || other.eveningAzkarTime == eveningAzkarTime)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&const DeepCollectionEquality().equals(other._salaahSettings, _salaahSettings)&&(identical(other.isAzanVoiceDownloading, isAzanVoiceDownloading) || other.isAzanVoiceDownloading == isAzanVoiceDownloading));
}


@override
int get hashCode => Object.hash(runtimeType,locale,latitude,longitude,cityName,calculationMethod,madhab,morningAzkarTime,eveningAzkarTime,const DeepCollectionEquality().hash(_reminders),const DeepCollectionEquality().hash(_salaahSettings),isAzanVoiceDownloading);

@override
String toString() {
  return 'SettingsState(locale: $locale, latitude: $latitude, longitude: $longitude, cityName: $cityName, calculationMethod: $calculationMethod, madhab: $madhab, morningAzkarTime: $morningAzkarTime, eveningAzkarTime: $eveningAzkarTime, reminders: $reminders, salaahSettings: $salaahSettings, isAzanVoiceDownloading: $isAzanVoiceDownloading)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 Locale locale, double? latitude, double? longitude, String? cityName, String calculationMethod, String madhab, String morningAzkarTime, String eveningAzkarTime, List<AzkarReminder> reminders, List<SalaahSettings> salaahSettings, bool isAzanVoiceDownloading
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? latitude = freezed,Object? longitude = freezed,Object? cityName = freezed,Object? calculationMethod = null,Object? madhab = null,Object? morningAzkarTime = null,Object? eveningAzkarTime = null,Object? reminders = null,Object? salaahSettings = null,Object? isAzanVoiceDownloading = null,}) {
  return _then(_SettingsState(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as Locale,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,calculationMethod: null == calculationMethod ? _self.calculationMethod : calculationMethod // ignore: cast_nullable_to_non_nullable
as String,madhab: null == madhab ? _self.madhab : madhab // ignore: cast_nullable_to_non_nullable
as String,morningAzkarTime: null == morningAzkarTime ? _self.morningAzkarTime : morningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,eveningAzkarTime: null == eveningAzkarTime ? _self.eveningAzkarTime : eveningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<AzkarReminder>,salaahSettings: null == salaahSettings ? _self._salaahSettings : salaahSettings // ignore: cast_nullable_to_non_nullable
as List<SalaahSettings>,isAzanVoiceDownloading: null == isAzanVoiceDownloading ? _self.isAzanVoiceDownloading : isAzanVoiceDownloading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
