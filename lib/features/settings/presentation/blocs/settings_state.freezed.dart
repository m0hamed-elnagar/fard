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

 Locale get locale; double? get latitude; double? get longitude; String? get cityName; String get calculationMethod; String get madhab; String get morningAzkarTime; String get eveningAzkarTime; bool get isAfterSalahAzkarEnabled; List<AzkarReminder> get reminders; List<SalaahSettings> get salaahSettings; bool get isAzanVoiceDownloading; bool get isQadaEnabled; int get hijriAdjustment; String get themePresetId; Map<String, String>? get customThemeColors; List<CustomTheme> get savedCustomThemes; String? get activeCustomThemeId; LocationStatus? get lastLocationStatus; AudioQuality get audioQuality; bool get isAudioPlayerExpanded;// Reminders
 bool get isSalahReminderEnabled; int get salahReminderOffsetMinutes; PrayerReminderType get prayerReminderType; Set<Salaah> get enabledSalahReminders; bool get isWerdReminderEnabled; String get werdReminderTime; bool get isSalawatReminderEnabled; int get salawatFrequencyHours; String get salawatStartTime; String get salawatEndTime;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.calculationMethod, calculationMethod) || other.calculationMethod == calculationMethod)&&(identical(other.madhab, madhab) || other.madhab == madhab)&&(identical(other.morningAzkarTime, morningAzkarTime) || other.morningAzkarTime == morningAzkarTime)&&(identical(other.eveningAzkarTime, eveningAzkarTime) || other.eveningAzkarTime == eveningAzkarTime)&&(identical(other.isAfterSalahAzkarEnabled, isAfterSalahAzkarEnabled) || other.isAfterSalahAzkarEnabled == isAfterSalahAzkarEnabled)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&const DeepCollectionEquality().equals(other.salaahSettings, salaahSettings)&&(identical(other.isAzanVoiceDownloading, isAzanVoiceDownloading) || other.isAzanVoiceDownloading == isAzanVoiceDownloading)&&(identical(other.isQadaEnabled, isQadaEnabled) || other.isQadaEnabled == isQadaEnabled)&&(identical(other.hijriAdjustment, hijriAdjustment) || other.hijriAdjustment == hijriAdjustment)&&(identical(other.themePresetId, themePresetId) || other.themePresetId == themePresetId)&&const DeepCollectionEquality().equals(other.customThemeColors, customThemeColors)&&const DeepCollectionEquality().equals(other.savedCustomThemes, savedCustomThemes)&&(identical(other.activeCustomThemeId, activeCustomThemeId) || other.activeCustomThemeId == activeCustomThemeId)&&(identical(other.lastLocationStatus, lastLocationStatus) || other.lastLocationStatus == lastLocationStatus)&&(identical(other.audioQuality, audioQuality) || other.audioQuality == audioQuality)&&(identical(other.isAudioPlayerExpanded, isAudioPlayerExpanded) || other.isAudioPlayerExpanded == isAudioPlayerExpanded)&&(identical(other.isSalahReminderEnabled, isSalahReminderEnabled) || other.isSalahReminderEnabled == isSalahReminderEnabled)&&(identical(other.salahReminderOffsetMinutes, salahReminderOffsetMinutes) || other.salahReminderOffsetMinutes == salahReminderOffsetMinutes)&&(identical(other.prayerReminderType, prayerReminderType) || other.prayerReminderType == prayerReminderType)&&const DeepCollectionEquality().equals(other.enabledSalahReminders, enabledSalahReminders)&&(identical(other.isWerdReminderEnabled, isWerdReminderEnabled) || other.isWerdReminderEnabled == isWerdReminderEnabled)&&(identical(other.werdReminderTime, werdReminderTime) || other.werdReminderTime == werdReminderTime)&&(identical(other.isSalawatReminderEnabled, isSalawatReminderEnabled) || other.isSalawatReminderEnabled == isSalawatReminderEnabled)&&(identical(other.salawatFrequencyHours, salawatFrequencyHours) || other.salawatFrequencyHours == salawatFrequencyHours)&&(identical(other.salawatStartTime, salawatStartTime) || other.salawatStartTime == salawatStartTime)&&(identical(other.salawatEndTime, salawatEndTime) || other.salawatEndTime == salawatEndTime));
}


@override
int get hashCode => Object.hashAll([runtimeType,locale,latitude,longitude,cityName,calculationMethod,madhab,morningAzkarTime,eveningAzkarTime,isAfterSalahAzkarEnabled,const DeepCollectionEquality().hash(reminders),const DeepCollectionEquality().hash(salaahSettings),isAzanVoiceDownloading,isQadaEnabled,hijriAdjustment,themePresetId,const DeepCollectionEquality().hash(customThemeColors),const DeepCollectionEquality().hash(savedCustomThemes),activeCustomThemeId,lastLocationStatus,audioQuality,isAudioPlayerExpanded,isSalahReminderEnabled,salahReminderOffsetMinutes,prayerReminderType,const DeepCollectionEquality().hash(enabledSalahReminders),isWerdReminderEnabled,werdReminderTime,isSalawatReminderEnabled,salawatFrequencyHours,salawatStartTime,salawatEndTime]);

@override
String toString() {
  return 'SettingsState(locale: $locale, latitude: $latitude, longitude: $longitude, cityName: $cityName, calculationMethod: $calculationMethod, madhab: $madhab, morningAzkarTime: $morningAzkarTime, eveningAzkarTime: $eveningAzkarTime, isAfterSalahAzkarEnabled: $isAfterSalahAzkarEnabled, reminders: $reminders, salaahSettings: $salaahSettings, isAzanVoiceDownloading: $isAzanVoiceDownloading, isQadaEnabled: $isQadaEnabled, hijriAdjustment: $hijriAdjustment, themePresetId: $themePresetId, customThemeColors: $customThemeColors, savedCustomThemes: $savedCustomThemes, activeCustomThemeId: $activeCustomThemeId, lastLocationStatus: $lastLocationStatus, audioQuality: $audioQuality, isAudioPlayerExpanded: $isAudioPlayerExpanded, isSalahReminderEnabled: $isSalahReminderEnabled, salahReminderOffsetMinutes: $salahReminderOffsetMinutes, prayerReminderType: $prayerReminderType, enabledSalahReminders: $enabledSalahReminders, isWerdReminderEnabled: $isWerdReminderEnabled, werdReminderTime: $werdReminderTime, isSalawatReminderEnabled: $isSalawatReminderEnabled, salawatFrequencyHours: $salawatFrequencyHours, salawatStartTime: $salawatStartTime, salawatEndTime: $salawatEndTime)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 Locale locale, double? latitude, double? longitude, String? cityName, String calculationMethod, String madhab, String morningAzkarTime, String eveningAzkarTime, bool isAfterSalahAzkarEnabled, List<AzkarReminder> reminders, List<SalaahSettings> salaahSettings, bool isAzanVoiceDownloading, bool isQadaEnabled, int hijriAdjustment, String themePresetId, Map<String, String>? customThemeColors, List<CustomTheme> savedCustomThemes, String? activeCustomThemeId, LocationStatus? lastLocationStatus, AudioQuality audioQuality, bool isAudioPlayerExpanded, bool isSalahReminderEnabled, int salahReminderOffsetMinutes, PrayerReminderType prayerReminderType, Set<Salaah> enabledSalahReminders, bool isWerdReminderEnabled, String werdReminderTime, bool isSalawatReminderEnabled, int salawatFrequencyHours, String salawatStartTime, String salawatEndTime
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
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? latitude = freezed,Object? longitude = freezed,Object? cityName = freezed,Object? calculationMethod = null,Object? madhab = null,Object? morningAzkarTime = null,Object? eveningAzkarTime = null,Object? isAfterSalahAzkarEnabled = null,Object? reminders = null,Object? salaahSettings = null,Object? isAzanVoiceDownloading = null,Object? isQadaEnabled = null,Object? hijriAdjustment = null,Object? themePresetId = null,Object? customThemeColors = freezed,Object? savedCustomThemes = null,Object? activeCustomThemeId = freezed,Object? lastLocationStatus = freezed,Object? audioQuality = null,Object? isAudioPlayerExpanded = null,Object? isSalahReminderEnabled = null,Object? salahReminderOffsetMinutes = null,Object? prayerReminderType = null,Object? enabledSalahReminders = null,Object? isWerdReminderEnabled = null,Object? werdReminderTime = null,Object? isSalawatReminderEnabled = null,Object? salawatFrequencyHours = null,Object? salawatStartTime = null,Object? salawatEndTime = null,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as Locale,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,calculationMethod: null == calculationMethod ? _self.calculationMethod : calculationMethod // ignore: cast_nullable_to_non_nullable
as String,madhab: null == madhab ? _self.madhab : madhab // ignore: cast_nullable_to_non_nullable
as String,morningAzkarTime: null == morningAzkarTime ? _self.morningAzkarTime : morningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,eveningAzkarTime: null == eveningAzkarTime ? _self.eveningAzkarTime : eveningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,isAfterSalahAzkarEnabled: null == isAfterSalahAzkarEnabled ? _self.isAfterSalahAzkarEnabled : isAfterSalahAzkarEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<AzkarReminder>,salaahSettings: null == salaahSettings ? _self.salaahSettings : salaahSettings // ignore: cast_nullable_to_non_nullable
as List<SalaahSettings>,isAzanVoiceDownloading: null == isAzanVoiceDownloading ? _self.isAzanVoiceDownloading : isAzanVoiceDownloading // ignore: cast_nullable_to_non_nullable
as bool,isQadaEnabled: null == isQadaEnabled ? _self.isQadaEnabled : isQadaEnabled // ignore: cast_nullable_to_non_nullable
as bool,hijriAdjustment: null == hijriAdjustment ? _self.hijriAdjustment : hijriAdjustment // ignore: cast_nullable_to_non_nullable
as int,themePresetId: null == themePresetId ? _self.themePresetId : themePresetId // ignore: cast_nullable_to_non_nullable
as String,customThemeColors: freezed == customThemeColors ? _self.customThemeColors : customThemeColors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,savedCustomThemes: null == savedCustomThemes ? _self.savedCustomThemes : savedCustomThemes // ignore: cast_nullable_to_non_nullable
as List<CustomTheme>,activeCustomThemeId: freezed == activeCustomThemeId ? _self.activeCustomThemeId : activeCustomThemeId // ignore: cast_nullable_to_non_nullable
as String?,lastLocationStatus: freezed == lastLocationStatus ? _self.lastLocationStatus : lastLocationStatus // ignore: cast_nullable_to_non_nullable
as LocationStatus?,audioQuality: null == audioQuality ? _self.audioQuality : audioQuality // ignore: cast_nullable_to_non_nullable
as AudioQuality,isAudioPlayerExpanded: null == isAudioPlayerExpanded ? _self.isAudioPlayerExpanded : isAudioPlayerExpanded // ignore: cast_nullable_to_non_nullable
as bool,isSalahReminderEnabled: null == isSalahReminderEnabled ? _self.isSalahReminderEnabled : isSalahReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,salahReminderOffsetMinutes: null == salahReminderOffsetMinutes ? _self.salahReminderOffsetMinutes : salahReminderOffsetMinutes // ignore: cast_nullable_to_non_nullable
as int,prayerReminderType: null == prayerReminderType ? _self.prayerReminderType : prayerReminderType // ignore: cast_nullable_to_non_nullable
as PrayerReminderType,enabledSalahReminders: null == enabledSalahReminders ? _self.enabledSalahReminders : enabledSalahReminders // ignore: cast_nullable_to_non_nullable
as Set<Salaah>,isWerdReminderEnabled: null == isWerdReminderEnabled ? _self.isWerdReminderEnabled : isWerdReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,werdReminderTime: null == werdReminderTime ? _self.werdReminderTime : werdReminderTime // ignore: cast_nullable_to_non_nullable
as String,isSalawatReminderEnabled: null == isSalawatReminderEnabled ? _self.isSalawatReminderEnabled : isSalawatReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,salawatFrequencyHours: null == salawatFrequencyHours ? _self.salawatFrequencyHours : salawatFrequencyHours // ignore: cast_nullable_to_non_nullable
as int,salawatStartTime: null == salawatStartTime ? _self.salawatStartTime : salawatStartTime // ignore: cast_nullable_to_non_nullable
as String,salawatEndTime: null == salawatEndTime ? _self.salawatEndTime : salawatEndTime // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Locale locale,  double? latitude,  double? longitude,  String? cityName,  String calculationMethod,  String madhab,  String morningAzkarTime,  String eveningAzkarTime,  bool isAfterSalahAzkarEnabled,  List<AzkarReminder> reminders,  List<SalaahSettings> salaahSettings,  bool isAzanVoiceDownloading,  bool isQadaEnabled,  int hijriAdjustment,  String themePresetId,  Map<String, String>? customThemeColors,  List<CustomTheme> savedCustomThemes,  String? activeCustomThemeId,  LocationStatus? lastLocationStatus,  AudioQuality audioQuality,  bool isAudioPlayerExpanded,  bool isSalahReminderEnabled,  int salahReminderOffsetMinutes,  PrayerReminderType prayerReminderType,  Set<Salaah> enabledSalahReminders,  bool isWerdReminderEnabled,  String werdReminderTime,  bool isSalawatReminderEnabled,  int salawatFrequencyHours,  String salawatStartTime,  String salawatEndTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.locale,_that.latitude,_that.longitude,_that.cityName,_that.calculationMethod,_that.madhab,_that.morningAzkarTime,_that.eveningAzkarTime,_that.isAfterSalahAzkarEnabled,_that.reminders,_that.salaahSettings,_that.isAzanVoiceDownloading,_that.isQadaEnabled,_that.hijriAdjustment,_that.themePresetId,_that.customThemeColors,_that.savedCustomThemes,_that.activeCustomThemeId,_that.lastLocationStatus,_that.audioQuality,_that.isAudioPlayerExpanded,_that.isSalahReminderEnabled,_that.salahReminderOffsetMinutes,_that.prayerReminderType,_that.enabledSalahReminders,_that.isWerdReminderEnabled,_that.werdReminderTime,_that.isSalawatReminderEnabled,_that.salawatFrequencyHours,_that.salawatStartTime,_that.salawatEndTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Locale locale,  double? latitude,  double? longitude,  String? cityName,  String calculationMethod,  String madhab,  String morningAzkarTime,  String eveningAzkarTime,  bool isAfterSalahAzkarEnabled,  List<AzkarReminder> reminders,  List<SalaahSettings> salaahSettings,  bool isAzanVoiceDownloading,  bool isQadaEnabled,  int hijriAdjustment,  String themePresetId,  Map<String, String>? customThemeColors,  List<CustomTheme> savedCustomThemes,  String? activeCustomThemeId,  LocationStatus? lastLocationStatus,  AudioQuality audioQuality,  bool isAudioPlayerExpanded,  bool isSalahReminderEnabled,  int salahReminderOffsetMinutes,  PrayerReminderType prayerReminderType,  Set<Salaah> enabledSalahReminders,  bool isWerdReminderEnabled,  String werdReminderTime,  bool isSalawatReminderEnabled,  int salawatFrequencyHours,  String salawatStartTime,  String salawatEndTime)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.locale,_that.latitude,_that.longitude,_that.cityName,_that.calculationMethod,_that.madhab,_that.morningAzkarTime,_that.eveningAzkarTime,_that.isAfterSalahAzkarEnabled,_that.reminders,_that.salaahSettings,_that.isAzanVoiceDownloading,_that.isQadaEnabled,_that.hijriAdjustment,_that.themePresetId,_that.customThemeColors,_that.savedCustomThemes,_that.activeCustomThemeId,_that.lastLocationStatus,_that.audioQuality,_that.isAudioPlayerExpanded,_that.isSalahReminderEnabled,_that.salahReminderOffsetMinutes,_that.prayerReminderType,_that.enabledSalahReminders,_that.isWerdReminderEnabled,_that.werdReminderTime,_that.isSalawatReminderEnabled,_that.salawatFrequencyHours,_that.salawatStartTime,_that.salawatEndTime);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Locale locale,  double? latitude,  double? longitude,  String? cityName,  String calculationMethod,  String madhab,  String morningAzkarTime,  String eveningAzkarTime,  bool isAfterSalahAzkarEnabled,  List<AzkarReminder> reminders,  List<SalaahSettings> salaahSettings,  bool isAzanVoiceDownloading,  bool isQadaEnabled,  int hijriAdjustment,  String themePresetId,  Map<String, String>? customThemeColors,  List<CustomTheme> savedCustomThemes,  String? activeCustomThemeId,  LocationStatus? lastLocationStatus,  AudioQuality audioQuality,  bool isAudioPlayerExpanded,  bool isSalahReminderEnabled,  int salahReminderOffsetMinutes,  PrayerReminderType prayerReminderType,  Set<Salaah> enabledSalahReminders,  bool isWerdReminderEnabled,  String werdReminderTime,  bool isSalawatReminderEnabled,  int salawatFrequencyHours,  String salawatStartTime,  String salawatEndTime)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.locale,_that.latitude,_that.longitude,_that.cityName,_that.calculationMethod,_that.madhab,_that.morningAzkarTime,_that.eveningAzkarTime,_that.isAfterSalahAzkarEnabled,_that.reminders,_that.salaahSettings,_that.isAzanVoiceDownloading,_that.isQadaEnabled,_that.hijriAdjustment,_that.themePresetId,_that.customThemeColors,_that.savedCustomThemes,_that.activeCustomThemeId,_that.lastLocationStatus,_that.audioQuality,_that.isAudioPlayerExpanded,_that.isSalahReminderEnabled,_that.salahReminderOffsetMinutes,_that.prayerReminderType,_that.enabledSalahReminders,_that.isWerdReminderEnabled,_that.werdReminderTime,_that.isSalawatReminderEnabled,_that.salawatFrequencyHours,_that.salawatStartTime,_that.salawatEndTime);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({required this.locale, this.latitude, this.longitude, this.cityName, this.calculationMethod = 'muslim_league', this.madhab = 'shafi', this.morningAzkarTime = '05:00', this.eveningAzkarTime = '18:00', this.isAfterSalahAzkarEnabled = false, final  List<AzkarReminder> reminders = const [], final  List<SalaahSettings> salaahSettings = const [], this.isAzanVoiceDownloading = false, this.isQadaEnabled = true, this.hijriAdjustment = 0, this.themePresetId = 'emerald', final  Map<String, String>? customThemeColors, final  List<CustomTheme> savedCustomThemes = const [], this.activeCustomThemeId, this.lastLocationStatus = null, this.audioQuality = AudioQuality.low64, this.isAudioPlayerExpanded = false, this.isSalahReminderEnabled = false, this.salahReminderOffsetMinutes = 15, this.prayerReminderType = PrayerReminderType.after, final  Set<Salaah> enabledSalahReminders = const {}, this.isWerdReminderEnabled = false, this.werdReminderTime = '20:00', this.isSalawatReminderEnabled = false, this.salawatFrequencyHours = 3, this.salawatStartTime = '10:00', this.salawatEndTime = '20:00'}): _reminders = reminders,_salaahSettings = salaahSettings,_customThemeColors = customThemeColors,_savedCustomThemes = savedCustomThemes,_enabledSalahReminders = enabledSalahReminders;
  

@override final  Locale locale;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? cityName;
@override@JsonKey() final  String calculationMethod;
@override@JsonKey() final  String madhab;
@override@JsonKey() final  String morningAzkarTime;
@override@JsonKey() final  String eveningAzkarTime;
@override@JsonKey() final  bool isAfterSalahAzkarEnabled;
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
@override@JsonKey() final  bool isQadaEnabled;
@override@JsonKey() final  int hijriAdjustment;
@override@JsonKey() final  String themePresetId;
 final  Map<String, String>? _customThemeColors;
@override Map<String, String>? get customThemeColors {
  final value = _customThemeColors;
  if (value == null) return null;
  if (_customThemeColors is EqualUnmodifiableMapView) return _customThemeColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<CustomTheme> _savedCustomThemes;
@override@JsonKey() List<CustomTheme> get savedCustomThemes {
  if (_savedCustomThemes is EqualUnmodifiableListView) return _savedCustomThemes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedCustomThemes);
}

@override final  String? activeCustomThemeId;
@override@JsonKey() final  LocationStatus? lastLocationStatus;
@override@JsonKey() final  AudioQuality audioQuality;
@override@JsonKey() final  bool isAudioPlayerExpanded;
// Reminders
@override@JsonKey() final  bool isSalahReminderEnabled;
@override@JsonKey() final  int salahReminderOffsetMinutes;
@override@JsonKey() final  PrayerReminderType prayerReminderType;
 final  Set<Salaah> _enabledSalahReminders;
@override@JsonKey() Set<Salaah> get enabledSalahReminders {
  if (_enabledSalahReminders is EqualUnmodifiableSetView) return _enabledSalahReminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_enabledSalahReminders);
}

@override@JsonKey() final  bool isWerdReminderEnabled;
@override@JsonKey() final  String werdReminderTime;
@override@JsonKey() final  bool isSalawatReminderEnabled;
@override@JsonKey() final  int salawatFrequencyHours;
@override@JsonKey() final  String salawatStartTime;
@override@JsonKey() final  String salawatEndTime;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.calculationMethod, calculationMethod) || other.calculationMethod == calculationMethod)&&(identical(other.madhab, madhab) || other.madhab == madhab)&&(identical(other.morningAzkarTime, morningAzkarTime) || other.morningAzkarTime == morningAzkarTime)&&(identical(other.eveningAzkarTime, eveningAzkarTime) || other.eveningAzkarTime == eveningAzkarTime)&&(identical(other.isAfterSalahAzkarEnabled, isAfterSalahAzkarEnabled) || other.isAfterSalahAzkarEnabled == isAfterSalahAzkarEnabled)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&const DeepCollectionEquality().equals(other._salaahSettings, _salaahSettings)&&(identical(other.isAzanVoiceDownloading, isAzanVoiceDownloading) || other.isAzanVoiceDownloading == isAzanVoiceDownloading)&&(identical(other.isQadaEnabled, isQadaEnabled) || other.isQadaEnabled == isQadaEnabled)&&(identical(other.hijriAdjustment, hijriAdjustment) || other.hijriAdjustment == hijriAdjustment)&&(identical(other.themePresetId, themePresetId) || other.themePresetId == themePresetId)&&const DeepCollectionEquality().equals(other._customThemeColors, _customThemeColors)&&const DeepCollectionEquality().equals(other._savedCustomThemes, _savedCustomThemes)&&(identical(other.activeCustomThemeId, activeCustomThemeId) || other.activeCustomThemeId == activeCustomThemeId)&&(identical(other.lastLocationStatus, lastLocationStatus) || other.lastLocationStatus == lastLocationStatus)&&(identical(other.audioQuality, audioQuality) || other.audioQuality == audioQuality)&&(identical(other.isAudioPlayerExpanded, isAudioPlayerExpanded) || other.isAudioPlayerExpanded == isAudioPlayerExpanded)&&(identical(other.isSalahReminderEnabled, isSalahReminderEnabled) || other.isSalahReminderEnabled == isSalahReminderEnabled)&&(identical(other.salahReminderOffsetMinutes, salahReminderOffsetMinutes) || other.salahReminderOffsetMinutes == salahReminderOffsetMinutes)&&(identical(other.prayerReminderType, prayerReminderType) || other.prayerReminderType == prayerReminderType)&&const DeepCollectionEquality().equals(other._enabledSalahReminders, _enabledSalahReminders)&&(identical(other.isWerdReminderEnabled, isWerdReminderEnabled) || other.isWerdReminderEnabled == isWerdReminderEnabled)&&(identical(other.werdReminderTime, werdReminderTime) || other.werdReminderTime == werdReminderTime)&&(identical(other.isSalawatReminderEnabled, isSalawatReminderEnabled) || other.isSalawatReminderEnabled == isSalawatReminderEnabled)&&(identical(other.salawatFrequencyHours, salawatFrequencyHours) || other.salawatFrequencyHours == salawatFrequencyHours)&&(identical(other.salawatStartTime, salawatStartTime) || other.salawatStartTime == salawatStartTime)&&(identical(other.salawatEndTime, salawatEndTime) || other.salawatEndTime == salawatEndTime));
}


@override
int get hashCode => Object.hashAll([runtimeType,locale,latitude,longitude,cityName,calculationMethod,madhab,morningAzkarTime,eveningAzkarTime,isAfterSalahAzkarEnabled,const DeepCollectionEquality().hash(_reminders),const DeepCollectionEquality().hash(_salaahSettings),isAzanVoiceDownloading,isQadaEnabled,hijriAdjustment,themePresetId,const DeepCollectionEquality().hash(_customThemeColors),const DeepCollectionEquality().hash(_savedCustomThemes),activeCustomThemeId,lastLocationStatus,audioQuality,isAudioPlayerExpanded,isSalahReminderEnabled,salahReminderOffsetMinutes,prayerReminderType,const DeepCollectionEquality().hash(_enabledSalahReminders),isWerdReminderEnabled,werdReminderTime,isSalawatReminderEnabled,salawatFrequencyHours,salawatStartTime,salawatEndTime]);

@override
String toString() {
  return 'SettingsState(locale: $locale, latitude: $latitude, longitude: $longitude, cityName: $cityName, calculationMethod: $calculationMethod, madhab: $madhab, morningAzkarTime: $morningAzkarTime, eveningAzkarTime: $eveningAzkarTime, isAfterSalahAzkarEnabled: $isAfterSalahAzkarEnabled, reminders: $reminders, salaahSettings: $salaahSettings, isAzanVoiceDownloading: $isAzanVoiceDownloading, isQadaEnabled: $isQadaEnabled, hijriAdjustment: $hijriAdjustment, themePresetId: $themePresetId, customThemeColors: $customThemeColors, savedCustomThemes: $savedCustomThemes, activeCustomThemeId: $activeCustomThemeId, lastLocationStatus: $lastLocationStatus, audioQuality: $audioQuality, isAudioPlayerExpanded: $isAudioPlayerExpanded, isSalahReminderEnabled: $isSalahReminderEnabled, salahReminderOffsetMinutes: $salahReminderOffsetMinutes, prayerReminderType: $prayerReminderType, enabledSalahReminders: $enabledSalahReminders, isWerdReminderEnabled: $isWerdReminderEnabled, werdReminderTime: $werdReminderTime, isSalawatReminderEnabled: $isSalawatReminderEnabled, salawatFrequencyHours: $salawatFrequencyHours, salawatStartTime: $salawatStartTime, salawatEndTime: $salawatEndTime)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 Locale locale, double? latitude, double? longitude, String? cityName, String calculationMethod, String madhab, String morningAzkarTime, String eveningAzkarTime, bool isAfterSalahAzkarEnabled, List<AzkarReminder> reminders, List<SalaahSettings> salaahSettings, bool isAzanVoiceDownloading, bool isQadaEnabled, int hijriAdjustment, String themePresetId, Map<String, String>? customThemeColors, List<CustomTheme> savedCustomThemes, String? activeCustomThemeId, LocationStatus? lastLocationStatus, AudioQuality audioQuality, bool isAudioPlayerExpanded, bool isSalahReminderEnabled, int salahReminderOffsetMinutes, PrayerReminderType prayerReminderType, Set<Salaah> enabledSalahReminders, bool isWerdReminderEnabled, String werdReminderTime, bool isSalawatReminderEnabled, int salawatFrequencyHours, String salawatStartTime, String salawatEndTime
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
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? latitude = freezed,Object? longitude = freezed,Object? cityName = freezed,Object? calculationMethod = null,Object? madhab = null,Object? morningAzkarTime = null,Object? eveningAzkarTime = null,Object? isAfterSalahAzkarEnabled = null,Object? reminders = null,Object? salaahSettings = null,Object? isAzanVoiceDownloading = null,Object? isQadaEnabled = null,Object? hijriAdjustment = null,Object? themePresetId = null,Object? customThemeColors = freezed,Object? savedCustomThemes = null,Object? activeCustomThemeId = freezed,Object? lastLocationStatus = freezed,Object? audioQuality = null,Object? isAudioPlayerExpanded = null,Object? isSalahReminderEnabled = null,Object? salahReminderOffsetMinutes = null,Object? prayerReminderType = null,Object? enabledSalahReminders = null,Object? isWerdReminderEnabled = null,Object? werdReminderTime = null,Object? isSalawatReminderEnabled = null,Object? salawatFrequencyHours = null,Object? salawatStartTime = null,Object? salawatEndTime = null,}) {
  return _then(_SettingsState(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as Locale,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,calculationMethod: null == calculationMethod ? _self.calculationMethod : calculationMethod // ignore: cast_nullable_to_non_nullable
as String,madhab: null == madhab ? _self.madhab : madhab // ignore: cast_nullable_to_non_nullable
as String,morningAzkarTime: null == morningAzkarTime ? _self.morningAzkarTime : morningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,eveningAzkarTime: null == eveningAzkarTime ? _self.eveningAzkarTime : eveningAzkarTime // ignore: cast_nullable_to_non_nullable
as String,isAfterSalahAzkarEnabled: null == isAfterSalahAzkarEnabled ? _self.isAfterSalahAzkarEnabled : isAfterSalahAzkarEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<AzkarReminder>,salaahSettings: null == salaahSettings ? _self._salaahSettings : salaahSettings // ignore: cast_nullable_to_non_nullable
as List<SalaahSettings>,isAzanVoiceDownloading: null == isAzanVoiceDownloading ? _self.isAzanVoiceDownloading : isAzanVoiceDownloading // ignore: cast_nullable_to_non_nullable
as bool,isQadaEnabled: null == isQadaEnabled ? _self.isQadaEnabled : isQadaEnabled // ignore: cast_nullable_to_non_nullable
as bool,hijriAdjustment: null == hijriAdjustment ? _self.hijriAdjustment : hijriAdjustment // ignore: cast_nullable_to_non_nullable
as int,themePresetId: null == themePresetId ? _self.themePresetId : themePresetId // ignore: cast_nullable_to_non_nullable
as String,customThemeColors: freezed == customThemeColors ? _self._customThemeColors : customThemeColors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,savedCustomThemes: null == savedCustomThemes ? _self._savedCustomThemes : savedCustomThemes // ignore: cast_nullable_to_non_nullable
as List<CustomTheme>,activeCustomThemeId: freezed == activeCustomThemeId ? _self.activeCustomThemeId : activeCustomThemeId // ignore: cast_nullable_to_non_nullable
as String?,lastLocationStatus: freezed == lastLocationStatus ? _self.lastLocationStatus : lastLocationStatus // ignore: cast_nullable_to_non_nullable
as LocationStatus?,audioQuality: null == audioQuality ? _self.audioQuality : audioQuality // ignore: cast_nullable_to_non_nullable
as AudioQuality,isAudioPlayerExpanded: null == isAudioPlayerExpanded ? _self.isAudioPlayerExpanded : isAudioPlayerExpanded // ignore: cast_nullable_to_non_nullable
as bool,isSalahReminderEnabled: null == isSalahReminderEnabled ? _self.isSalahReminderEnabled : isSalahReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,salahReminderOffsetMinutes: null == salahReminderOffsetMinutes ? _self.salahReminderOffsetMinutes : salahReminderOffsetMinutes // ignore: cast_nullable_to_non_nullable
as int,prayerReminderType: null == prayerReminderType ? _self.prayerReminderType : prayerReminderType // ignore: cast_nullable_to_non_nullable
as PrayerReminderType,enabledSalahReminders: null == enabledSalahReminders ? _self._enabledSalahReminders : enabledSalahReminders // ignore: cast_nullable_to_non_nullable
as Set<Salaah>,isWerdReminderEnabled: null == isWerdReminderEnabled ? _self.isWerdReminderEnabled : isWerdReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,werdReminderTime: null == werdReminderTime ? _self.werdReminderTime : werdReminderTime // ignore: cast_nullable_to_non_nullable
as String,isSalawatReminderEnabled: null == isSalawatReminderEnabled ? _self.isSalawatReminderEnabled : isSalawatReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,salawatFrequencyHours: null == salawatFrequencyHours ? _self.salawatFrequencyHours : salawatFrequencyHours // ignore: cast_nullable_to_non_nullable
as int,salawatStartTime: null == salawatStartTime ? _self.salawatStartTime : salawatStartTime // ignore: cast_nullable_to_non_nullable
as String,salawatEndTime: null == salawatEndTime ? _self.salawatEndTime : salawatEndTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
