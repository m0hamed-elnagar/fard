// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'salaah_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalaahSettings {

 Salaah get salaah; bool get isAzanEnabled; bool get isReminderEnabled; int get reminderMinutesBefore; bool get isAfterSalahAzkarEnabled; int get afterSalaahAzkarMinutes; String? get azanSound;
/// Create a copy of SalaahSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalaahSettingsCopyWith<SalaahSettings> get copyWith => _$SalaahSettingsCopyWithImpl<SalaahSettings>(this as SalaahSettings, _$identity);

  /// Serializes this SalaahSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalaahSettings&&(identical(other.salaah, salaah) || other.salaah == salaah)&&(identical(other.isAzanEnabled, isAzanEnabled) || other.isAzanEnabled == isAzanEnabled)&&(identical(other.isReminderEnabled, isReminderEnabled) || other.isReminderEnabled == isReminderEnabled)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore)&&(identical(other.isAfterSalahAzkarEnabled, isAfterSalahAzkarEnabled) || other.isAfterSalahAzkarEnabled == isAfterSalahAzkarEnabled)&&(identical(other.afterSalaahAzkarMinutes, afterSalaahAzkarMinutes) || other.afterSalaahAzkarMinutes == afterSalaahAzkarMinutes)&&(identical(other.azanSound, azanSound) || other.azanSound == azanSound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salaah,isAzanEnabled,isReminderEnabled,reminderMinutesBefore,isAfterSalahAzkarEnabled,afterSalaahAzkarMinutes,azanSound);

@override
String toString() {
  return 'SalaahSettings(salaah: $salaah, isAzanEnabled: $isAzanEnabled, isReminderEnabled: $isReminderEnabled, reminderMinutesBefore: $reminderMinutesBefore, isAfterSalahAzkarEnabled: $isAfterSalahAzkarEnabled, afterSalaahAzkarMinutes: $afterSalaahAzkarMinutes, azanSound: $azanSound)';
}


}

/// @nodoc
abstract mixin class $SalaahSettingsCopyWith<$Res>  {
  factory $SalaahSettingsCopyWith(SalaahSettings value, $Res Function(SalaahSettings) _then) = _$SalaahSettingsCopyWithImpl;
@useResult
$Res call({
 Salaah salaah, bool isAzanEnabled, bool isReminderEnabled, int reminderMinutesBefore, bool isAfterSalahAzkarEnabled, int afterSalaahAzkarMinutes, String? azanSound
});




}
/// @nodoc
class _$SalaahSettingsCopyWithImpl<$Res>
    implements $SalaahSettingsCopyWith<$Res> {
  _$SalaahSettingsCopyWithImpl(this._self, this._then);

  final SalaahSettings _self;
  final $Res Function(SalaahSettings) _then;

/// Create a copy of SalaahSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salaah = null,Object? isAzanEnabled = null,Object? isReminderEnabled = null,Object? reminderMinutesBefore = null,Object? isAfterSalahAzkarEnabled = null,Object? afterSalaahAzkarMinutes = null,Object? azanSound = freezed,}) {
  return _then(_self.copyWith(
salaah: null == salaah ? _self.salaah : salaah // ignore: cast_nullable_to_non_nullable
as Salaah,isAzanEnabled: null == isAzanEnabled ? _self.isAzanEnabled : isAzanEnabled // ignore: cast_nullable_to_non_nullable
as bool,isReminderEnabled: null == isReminderEnabled ? _self.isReminderEnabled : isReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderMinutesBefore: null == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int,isAfterSalahAzkarEnabled: null == isAfterSalahAzkarEnabled ? _self.isAfterSalahAzkarEnabled : isAfterSalahAzkarEnabled // ignore: cast_nullable_to_non_nullable
as bool,afterSalaahAzkarMinutes: null == afterSalaahAzkarMinutes ? _self.afterSalaahAzkarMinutes : afterSalaahAzkarMinutes // ignore: cast_nullable_to_non_nullable
as int,azanSound: freezed == azanSound ? _self.azanSound : azanSound // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalaahSettings].
extension SalaahSettingsPatterns on SalaahSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalaahSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalaahSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalaahSettings value)  $default,){
final _that = this;
switch (_that) {
case _SalaahSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalaahSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SalaahSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Salaah salaah,  bool isAzanEnabled,  bool isReminderEnabled,  int reminderMinutesBefore,  bool isAfterSalahAzkarEnabled,  int afterSalaahAzkarMinutes,  String? azanSound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalaahSettings() when $default != null:
return $default(_that.salaah,_that.isAzanEnabled,_that.isReminderEnabled,_that.reminderMinutesBefore,_that.isAfterSalahAzkarEnabled,_that.afterSalaahAzkarMinutes,_that.azanSound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Salaah salaah,  bool isAzanEnabled,  bool isReminderEnabled,  int reminderMinutesBefore,  bool isAfterSalahAzkarEnabled,  int afterSalaahAzkarMinutes,  String? azanSound)  $default,) {final _that = this;
switch (_that) {
case _SalaahSettings():
return $default(_that.salaah,_that.isAzanEnabled,_that.isReminderEnabled,_that.reminderMinutesBefore,_that.isAfterSalahAzkarEnabled,_that.afterSalaahAzkarMinutes,_that.azanSound);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Salaah salaah,  bool isAzanEnabled,  bool isReminderEnabled,  int reminderMinutesBefore,  bool isAfterSalahAzkarEnabled,  int afterSalaahAzkarMinutes,  String? azanSound)?  $default,) {final _that = this;
switch (_that) {
case _SalaahSettings() when $default != null:
return $default(_that.salaah,_that.isAzanEnabled,_that.isReminderEnabled,_that.reminderMinutesBefore,_that.isAfterSalahAzkarEnabled,_that.afterSalaahAzkarMinutes,_that.azanSound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalaahSettings implements SalaahSettings {
  const _SalaahSettings({required this.salaah, this.isAzanEnabled = true, this.isReminderEnabled = true, this.reminderMinutesBefore = 15, this.isAfterSalahAzkarEnabled = false, this.afterSalaahAzkarMinutes = 5, this.azanSound});
  factory _SalaahSettings.fromJson(Map<String, dynamic> json) => _$SalaahSettingsFromJson(json);

@override final  Salaah salaah;
@override@JsonKey() final  bool isAzanEnabled;
@override@JsonKey() final  bool isReminderEnabled;
@override@JsonKey() final  int reminderMinutesBefore;
@override@JsonKey() final  bool isAfterSalahAzkarEnabled;
@override@JsonKey() final  int afterSalaahAzkarMinutes;
@override final  String? azanSound;

/// Create a copy of SalaahSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalaahSettingsCopyWith<_SalaahSettings> get copyWith => __$SalaahSettingsCopyWithImpl<_SalaahSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalaahSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalaahSettings&&(identical(other.salaah, salaah) || other.salaah == salaah)&&(identical(other.isAzanEnabled, isAzanEnabled) || other.isAzanEnabled == isAzanEnabled)&&(identical(other.isReminderEnabled, isReminderEnabled) || other.isReminderEnabled == isReminderEnabled)&&(identical(other.reminderMinutesBefore, reminderMinutesBefore) || other.reminderMinutesBefore == reminderMinutesBefore)&&(identical(other.isAfterSalahAzkarEnabled, isAfterSalahAzkarEnabled) || other.isAfterSalahAzkarEnabled == isAfterSalahAzkarEnabled)&&(identical(other.afterSalaahAzkarMinutes, afterSalaahAzkarMinutes) || other.afterSalaahAzkarMinutes == afterSalaahAzkarMinutes)&&(identical(other.azanSound, azanSound) || other.azanSound == azanSound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salaah,isAzanEnabled,isReminderEnabled,reminderMinutesBefore,isAfterSalahAzkarEnabled,afterSalaahAzkarMinutes,azanSound);

@override
String toString() {
  return 'SalaahSettings(salaah: $salaah, isAzanEnabled: $isAzanEnabled, isReminderEnabled: $isReminderEnabled, reminderMinutesBefore: $reminderMinutesBefore, isAfterSalahAzkarEnabled: $isAfterSalahAzkarEnabled, afterSalaahAzkarMinutes: $afterSalaahAzkarMinutes, azanSound: $azanSound)';
}


}

/// @nodoc
abstract mixin class _$SalaahSettingsCopyWith<$Res> implements $SalaahSettingsCopyWith<$Res> {
  factory _$SalaahSettingsCopyWith(_SalaahSettings value, $Res Function(_SalaahSettings) _then) = __$SalaahSettingsCopyWithImpl;
@override @useResult
$Res call({
 Salaah salaah, bool isAzanEnabled, bool isReminderEnabled, int reminderMinutesBefore, bool isAfterSalahAzkarEnabled, int afterSalaahAzkarMinutes, String? azanSound
});




}
/// @nodoc
class __$SalaahSettingsCopyWithImpl<$Res>
    implements _$SalaahSettingsCopyWith<$Res> {
  __$SalaahSettingsCopyWithImpl(this._self, this._then);

  final _SalaahSettings _self;
  final $Res Function(_SalaahSettings) _then;

/// Create a copy of SalaahSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salaah = null,Object? isAzanEnabled = null,Object? isReminderEnabled = null,Object? reminderMinutesBefore = null,Object? isAfterSalahAzkarEnabled = null,Object? afterSalaahAzkarMinutes = null,Object? azanSound = freezed,}) {
  return _then(_SalaahSettings(
salaah: null == salaah ? _self.salaah : salaah // ignore: cast_nullable_to_non_nullable
as Salaah,isAzanEnabled: null == isAzanEnabled ? _self.isAzanEnabled : isAzanEnabled // ignore: cast_nullable_to_non_nullable
as bool,isReminderEnabled: null == isReminderEnabled ? _self.isReminderEnabled : isReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderMinutesBefore: null == reminderMinutesBefore ? _self.reminderMinutesBefore : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
as int,isAfterSalahAzkarEnabled: null == isAfterSalahAzkarEnabled ? _self.isAfterSalahAzkarEnabled : isAfterSalahAzkarEnabled // ignore: cast_nullable_to_non_nullable
as bool,afterSalaahAzkarMinutes: null == afterSalaahAzkarMinutes ? _self.afterSalaahAzkarMinutes : afterSalaahAzkarMinutes // ignore: cast_nullable_to_non_nullable
as int,azanSound: freezed == azanSound ? _self.azanSound : azanSound // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
