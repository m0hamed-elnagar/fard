// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_tracker_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PrayerTrackerEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayerTrackerEventCopyWith<$Res> {
  factory $PrayerTrackerEventCopyWith(
          PrayerTrackerEvent value, $Res Function(PrayerTrackerEvent) then) =
      _$PrayerTrackerEventCopyWithImpl<$Res, PrayerTrackerEvent>;
}

/// @nodoc
class _$PrayerTrackerEventCopyWithImpl<$Res, $Val extends PrayerTrackerEvent>
    implements $PrayerTrackerEventCopyWith<$Res> {
  _$PrayerTrackerEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LoadImplCopyWith<$Res> {
  factory _$$LoadImplCopyWith(
          _$LoadImpl value, $Res Function(_$LoadImpl) then) =
      __$$LoadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTime date});
}

/// @nodoc
class __$$LoadImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$LoadImpl>
    implements _$$LoadImplCopyWith<$Res> {
  __$$LoadImplCopyWithImpl(_$LoadImpl _value, $Res Function(_$LoadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
  }) {
    return _then(_$LoadImpl(
      null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$LoadImpl implements _Load {
  const _$LoadImpl(this.date);

  @override
  final DateTime date;

  @override
  String toString() {
    return 'PrayerTrackerEvent.load(date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadImpl &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadImplCopyWith<_$LoadImpl> get copyWith =>
      __$$LoadImplCopyWithImpl<_$LoadImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return load(date);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return load?.call(date);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(date);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _Load implements PrayerTrackerEvent {
  const factory _Load(final DateTime date) = _$LoadImpl;

  DateTime get date;
  @JsonKey(ignore: true)
  _$$LoadImplCopyWith<_$LoadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TogglePrayerImplCopyWith<$Res> {
  factory _$$TogglePrayerImplCopyWith(
          _$TogglePrayerImpl value, $Res Function(_$TogglePrayerImpl) then) =
      __$$TogglePrayerImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Salaah prayer});
}

/// @nodoc
class __$$TogglePrayerImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$TogglePrayerImpl>
    implements _$$TogglePrayerImplCopyWith<$Res> {
  __$$TogglePrayerImplCopyWithImpl(
      _$TogglePrayerImpl _value, $Res Function(_$TogglePrayerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prayer = null,
  }) {
    return _then(_$TogglePrayerImpl(
      null == prayer
          ? _value.prayer
          : prayer // ignore: cast_nullable_to_non_nullable
              as Salaah,
    ));
  }
}

/// @nodoc

class _$TogglePrayerImpl implements _TogglePrayer {
  const _$TogglePrayerImpl(this.prayer);

  @override
  final Salaah prayer;

  @override
  String toString() {
    return 'PrayerTrackerEvent.togglePrayer(prayer: $prayer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TogglePrayerImpl &&
            (identical(other.prayer, prayer) || other.prayer == prayer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, prayer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TogglePrayerImplCopyWith<_$TogglePrayerImpl> get copyWith =>
      __$$TogglePrayerImplCopyWithImpl<_$TogglePrayerImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return togglePrayer(prayer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return togglePrayer?.call(prayer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (togglePrayer != null) {
      return togglePrayer(prayer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return togglePrayer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return togglePrayer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (togglePrayer != null) {
      return togglePrayer(this);
    }
    return orElse();
  }
}

abstract class _TogglePrayer implements PrayerTrackerEvent {
  const factory _TogglePrayer(final Salaah prayer) = _$TogglePrayerImpl;

  Salaah get prayer;
  @JsonKey(ignore: true)
  _$$TogglePrayerImplCopyWith<_$TogglePrayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AddQadaImplCopyWith<$Res> {
  factory _$$AddQadaImplCopyWith(
          _$AddQadaImpl value, $Res Function(_$AddQadaImpl) then) =
      __$$AddQadaImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Salaah prayer});
}

/// @nodoc
class __$$AddQadaImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$AddQadaImpl>
    implements _$$AddQadaImplCopyWith<$Res> {
  __$$AddQadaImplCopyWithImpl(
      _$AddQadaImpl _value, $Res Function(_$AddQadaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prayer = null,
  }) {
    return _then(_$AddQadaImpl(
      null == prayer
          ? _value.prayer
          : prayer // ignore: cast_nullable_to_non_nullable
              as Salaah,
    ));
  }
}

/// @nodoc

class _$AddQadaImpl implements _AddQada {
  const _$AddQadaImpl(this.prayer);

  @override
  final Salaah prayer;

  @override
  String toString() {
    return 'PrayerTrackerEvent.addQada(prayer: $prayer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddQadaImpl &&
            (identical(other.prayer, prayer) || other.prayer == prayer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, prayer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddQadaImplCopyWith<_$AddQadaImpl> get copyWith =>
      __$$AddQadaImplCopyWithImpl<_$AddQadaImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return addQada(prayer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return addQada?.call(prayer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (addQada != null) {
      return addQada(prayer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return addQada(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return addQada?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (addQada != null) {
      return addQada(this);
    }
    return orElse();
  }
}

abstract class _AddQada implements PrayerTrackerEvent {
  const factory _AddQada(final Salaah prayer) = _$AddQadaImpl;

  Salaah get prayer;
  @JsonKey(ignore: true)
  _$$AddQadaImplCopyWith<_$AddQadaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RemoveQadaImplCopyWith<$Res> {
  factory _$$RemoveQadaImplCopyWith(
          _$RemoveQadaImpl value, $Res Function(_$RemoveQadaImpl) then) =
      __$$RemoveQadaImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Salaah prayer});
}

/// @nodoc
class __$$RemoveQadaImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$RemoveQadaImpl>
    implements _$$RemoveQadaImplCopyWith<$Res> {
  __$$RemoveQadaImplCopyWithImpl(
      _$RemoveQadaImpl _value, $Res Function(_$RemoveQadaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prayer = null,
  }) {
    return _then(_$RemoveQadaImpl(
      null == prayer
          ? _value.prayer
          : prayer // ignore: cast_nullable_to_non_nullable
              as Salaah,
    ));
  }
}

/// @nodoc

class _$RemoveQadaImpl implements _RemoveQada {
  const _$RemoveQadaImpl(this.prayer);

  @override
  final Salaah prayer;

  @override
  String toString() {
    return 'PrayerTrackerEvent.removeQada(prayer: $prayer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoveQadaImpl &&
            (identical(other.prayer, prayer) || other.prayer == prayer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, prayer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoveQadaImplCopyWith<_$RemoveQadaImpl> get copyWith =>
      __$$RemoveQadaImplCopyWithImpl<_$RemoveQadaImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return removeQada(prayer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return removeQada?.call(prayer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (removeQada != null) {
      return removeQada(prayer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return removeQada(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return removeQada?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (removeQada != null) {
      return removeQada(this);
    }
    return orElse();
  }
}

abstract class _RemoveQada implements PrayerTrackerEvent {
  const factory _RemoveQada(final Salaah prayer) = _$RemoveQadaImpl;

  Salaah get prayer;
  @JsonKey(ignore: true)
  _$$RemoveQadaImplCopyWith<_$RemoveQadaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SaveImplCopyWith<$Res> {
  factory _$$SaveImplCopyWith(
          _$SaveImpl value, $Res Function(_$SaveImpl) then) =
      __$$SaveImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SaveImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$SaveImpl>
    implements _$$SaveImplCopyWith<$Res> {
  __$$SaveImplCopyWithImpl(_$SaveImpl _value, $Res Function(_$SaveImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SaveImpl implements _Save {
  const _$SaveImpl();

  @override
  String toString() {
    return 'PrayerTrackerEvent.save()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SaveImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return save();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return save?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (save != null) {
      return save();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return save(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return save?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (save != null) {
      return save(this);
    }
    return orElse();
  }
}

abstract class _Save implements PrayerTrackerEvent {
  const factory _Save() = _$SaveImpl;
}

/// @nodoc
abstract class _$$LoadMonthImplCopyWith<$Res> {
  factory _$$LoadMonthImplCopyWith(
          _$LoadMonthImpl value, $Res Function(_$LoadMonthImpl) then) =
      __$$LoadMonthImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int year, int month});
}

/// @nodoc
class __$$LoadMonthImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$LoadMonthImpl>
    implements _$$LoadMonthImplCopyWith<$Res> {
  __$$LoadMonthImplCopyWithImpl(
      _$LoadMonthImpl _value, $Res Function(_$LoadMonthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
  }) {
    return _then(_$LoadMonthImpl(
      null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$LoadMonthImpl implements _LoadMonth {
  const _$LoadMonthImpl(this.year, this.month);

  @override
  final int year;
  @override
  final int month;

  @override
  String toString() {
    return 'PrayerTrackerEvent.loadMonth(year: $year, month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadMonthImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, month);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadMonthImplCopyWith<_$LoadMonthImpl> get copyWith =>
      __$$LoadMonthImplCopyWithImpl<_$LoadMonthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return loadMonth(year, month);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return loadMonth?.call(year, month);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (loadMonth != null) {
      return loadMonth(year, month);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return loadMonth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return loadMonth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (loadMonth != null) {
      return loadMonth(this);
    }
    return orElse();
  }
}

abstract class _LoadMonth implements PrayerTrackerEvent {
  const factory _LoadMonth(final int year, final int month) = _$LoadMonthImpl;

  int get year;
  int get month;
  @JsonKey(ignore: true)
  _$$LoadMonthImplCopyWith<_$LoadMonthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CheckMissedDaysImplCopyWith<$Res> {
  factory _$$CheckMissedDaysImplCopyWith(_$CheckMissedDaysImpl value,
          $Res Function(_$CheckMissedDaysImpl) then) =
      __$$CheckMissedDaysImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CheckMissedDaysImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$CheckMissedDaysImpl>
    implements _$$CheckMissedDaysImplCopyWith<$Res> {
  __$$CheckMissedDaysImplCopyWithImpl(
      _$CheckMissedDaysImpl _value, $Res Function(_$CheckMissedDaysImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$CheckMissedDaysImpl implements _CheckMissedDays {
  const _$CheckMissedDaysImpl();

  @override
  String toString() {
    return 'PrayerTrackerEvent.checkMissedDays()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CheckMissedDaysImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return checkMissedDays();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return checkMissedDays?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (checkMissedDays != null) {
      return checkMissedDays();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return checkMissedDays(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return checkMissedDays?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (checkMissedDays != null) {
      return checkMissedDays(this);
    }
    return orElse();
  }
}

abstract class _CheckMissedDays implements PrayerTrackerEvent {
  const factory _CheckMissedDays() = _$CheckMissedDaysImpl;
}

/// @nodoc
abstract class _$$AcknowledgeMissedDaysImplCopyWith<$Res> {
  factory _$$AcknowledgeMissedDaysImplCopyWith(
          _$AcknowledgeMissedDaysImpl value,
          $Res Function(_$AcknowledgeMissedDaysImpl) then) =
      __$$AcknowledgeMissedDaysImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<DateTime> dates, bool addAsMissed});
}

/// @nodoc
class __$$AcknowledgeMissedDaysImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$AcknowledgeMissedDaysImpl>
    implements _$$AcknowledgeMissedDaysImplCopyWith<$Res> {
  __$$AcknowledgeMissedDaysImplCopyWithImpl(_$AcknowledgeMissedDaysImpl _value,
      $Res Function(_$AcknowledgeMissedDaysImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dates = null,
    Object? addAsMissed = null,
  }) {
    return _then(_$AcknowledgeMissedDaysImpl(
      dates: null == dates
          ? _value._dates
          : dates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      addAsMissed: null == addAsMissed
          ? _value.addAsMissed
          : addAsMissed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AcknowledgeMissedDaysImpl implements _AcknowledgeMissedDays {
  const _$AcknowledgeMissedDaysImpl(
      {required final List<DateTime> dates, required this.addAsMissed})
      : _dates = dates;

  final List<DateTime> _dates;
  @override
  List<DateTime> get dates {
    if (_dates is EqualUnmodifiableListView) return _dates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dates);
  }

  @override
  final bool addAsMissed;

  @override
  String toString() {
    return 'PrayerTrackerEvent.acknowledgeMissedDays(dates: $dates, addAsMissed: $addAsMissed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcknowledgeMissedDaysImpl &&
            const DeepCollectionEquality().equals(other._dates, _dates) &&
            (identical(other.addAsMissed, addAsMissed) ||
                other.addAsMissed == addAsMissed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_dates), addAsMissed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AcknowledgeMissedDaysImplCopyWith<_$AcknowledgeMissedDaysImpl>
      get copyWith => __$$AcknowledgeMissedDaysImplCopyWithImpl<
          _$AcknowledgeMissedDaysImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return acknowledgeMissedDays(dates, addAsMissed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return acknowledgeMissedDays?.call(dates, addAsMissed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (acknowledgeMissedDays != null) {
      return acknowledgeMissedDays(dates, addAsMissed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return acknowledgeMissedDays(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return acknowledgeMissedDays?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (acknowledgeMissedDays != null) {
      return acknowledgeMissedDays(this);
    }
    return orElse();
  }
}

abstract class _AcknowledgeMissedDays implements PrayerTrackerEvent {
  const factory _AcknowledgeMissedDays(
      {required final List<DateTime> dates,
      required final bool addAsMissed}) = _$AcknowledgeMissedDaysImpl;

  List<DateTime> get dates;
  bool get addAsMissed;
  @JsonKey(ignore: true)
  _$$AcknowledgeMissedDaysImplCopyWith<_$AcknowledgeMissedDaysImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BulkAddQadaImplCopyWith<$Res> {
  factory _$$BulkAddQadaImplCopyWith(
          _$BulkAddQadaImpl value, $Res Function(_$BulkAddQadaImpl) then) =
      __$$BulkAddQadaImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<Salaah, int> counts});
}

/// @nodoc
class __$$BulkAddQadaImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$BulkAddQadaImpl>
    implements _$$BulkAddQadaImplCopyWith<$Res> {
  __$$BulkAddQadaImplCopyWithImpl(
      _$BulkAddQadaImpl _value, $Res Function(_$BulkAddQadaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? counts = null,
  }) {
    return _then(_$BulkAddQadaImpl(
      null == counts
          ? _value._counts
          : counts // ignore: cast_nullable_to_non_nullable
              as Map<Salaah, int>,
    ));
  }
}

/// @nodoc

class _$BulkAddQadaImpl implements _BulkAddQada {
  const _$BulkAddQadaImpl(final Map<Salaah, int> counts) : _counts = counts;

  final Map<Salaah, int> _counts;
  @override
  Map<Salaah, int> get counts {
    if (_counts is EqualUnmodifiableMapView) return _counts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_counts);
  }

  @override
  String toString() {
    return 'PrayerTrackerEvent.bulkAddQada(counts: $counts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulkAddQadaImpl &&
            const DeepCollectionEquality().equals(other._counts, _counts));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_counts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BulkAddQadaImplCopyWith<_$BulkAddQadaImpl> get copyWith =>
      __$$BulkAddQadaImplCopyWithImpl<_$BulkAddQadaImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return bulkAddQada(counts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return bulkAddQada?.call(counts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (bulkAddQada != null) {
      return bulkAddQada(counts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return bulkAddQada(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return bulkAddQada?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (bulkAddQada != null) {
      return bulkAddQada(this);
    }
    return orElse();
  }
}

abstract class _BulkAddQada implements PrayerTrackerEvent {
  const factory _BulkAddQada(final Map<Salaah, int> counts) = _$BulkAddQadaImpl;

  Map<Salaah, int> get counts;
  @JsonKey(ignore: true)
  _$$BulkAddQadaImplCopyWith<_$BulkAddQadaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteRecordImplCopyWith<$Res> {
  factory _$$DeleteRecordImplCopyWith(
          _$DeleteRecordImpl value, $Res Function(_$DeleteRecordImpl) then) =
      __$$DeleteRecordImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTime date});
}

/// @nodoc
class __$$DeleteRecordImplCopyWithImpl<$Res>
    extends _$PrayerTrackerEventCopyWithImpl<$Res, _$DeleteRecordImpl>
    implements _$$DeleteRecordImplCopyWith<$Res> {
  __$$DeleteRecordImplCopyWithImpl(
      _$DeleteRecordImpl _value, $Res Function(_$DeleteRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
  }) {
    return _then(_$DeleteRecordImpl(
      null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$DeleteRecordImpl implements _DeleteRecord {
  const _$DeleteRecordImpl(this.date);

  @override
  final DateTime date;

  @override
  String toString() {
    return 'PrayerTrackerEvent.deleteRecord(date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteRecordImpl &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteRecordImplCopyWith<_$DeleteRecordImpl> get copyWith =>
      __$$DeleteRecordImplCopyWithImpl<_$DeleteRecordImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime date) load,
    required TResult Function(Salaah prayer) togglePrayer,
    required TResult Function(Salaah prayer) addQada,
    required TResult Function(Salaah prayer) removeQada,
    required TResult Function() save,
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() checkMissedDays,
    required TResult Function(List<DateTime> dates, bool addAsMissed)
        acknowledgeMissedDays,
    required TResult Function(Map<Salaah, int> counts) bulkAddQada,
    required TResult Function(DateTime date) deleteRecord,
  }) {
    return deleteRecord(date);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime date)? load,
    TResult? Function(Salaah prayer)? togglePrayer,
    TResult? Function(Salaah prayer)? addQada,
    TResult? Function(Salaah prayer)? removeQada,
    TResult? Function()? save,
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? checkMissedDays,
    TResult? Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult? Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult? Function(DateTime date)? deleteRecord,
  }) {
    return deleteRecord?.call(date);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime date)? load,
    TResult Function(Salaah prayer)? togglePrayer,
    TResult Function(Salaah prayer)? addQada,
    TResult Function(Salaah prayer)? removeQada,
    TResult Function()? save,
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? checkMissedDays,
    TResult Function(List<DateTime> dates, bool addAsMissed)?
        acknowledgeMissedDays,
    TResult Function(Map<Salaah, int> counts)? bulkAddQada,
    TResult Function(DateTime date)? deleteRecord,
    required TResult orElse(),
  }) {
    if (deleteRecord != null) {
      return deleteRecord(date);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Load value) load,
    required TResult Function(_TogglePrayer value) togglePrayer,
    required TResult Function(_AddQada value) addQada,
    required TResult Function(_RemoveQada value) removeQada,
    required TResult Function(_Save value) save,
    required TResult Function(_LoadMonth value) loadMonth,
    required TResult Function(_CheckMissedDays value) checkMissedDays,
    required TResult Function(_AcknowledgeMissedDays value)
        acknowledgeMissedDays,
    required TResult Function(_BulkAddQada value) bulkAddQada,
    required TResult Function(_DeleteRecord value) deleteRecord,
  }) {
    return deleteRecord(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Load value)? load,
    TResult? Function(_TogglePrayer value)? togglePrayer,
    TResult? Function(_AddQada value)? addQada,
    TResult? Function(_RemoveQada value)? removeQada,
    TResult? Function(_Save value)? save,
    TResult? Function(_LoadMonth value)? loadMonth,
    TResult? Function(_CheckMissedDays value)? checkMissedDays,
    TResult? Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult? Function(_BulkAddQada value)? bulkAddQada,
    TResult? Function(_DeleteRecord value)? deleteRecord,
  }) {
    return deleteRecord?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Load value)? load,
    TResult Function(_TogglePrayer value)? togglePrayer,
    TResult Function(_AddQada value)? addQada,
    TResult Function(_RemoveQada value)? removeQada,
    TResult Function(_Save value)? save,
    TResult Function(_LoadMonth value)? loadMonth,
    TResult Function(_CheckMissedDays value)? checkMissedDays,
    TResult Function(_AcknowledgeMissedDays value)? acknowledgeMissedDays,
    TResult Function(_BulkAddQada value)? bulkAddQada,
    TResult Function(_DeleteRecord value)? deleteRecord,
    required TResult orElse(),
  }) {
    if (deleteRecord != null) {
      return deleteRecord(this);
    }
    return orElse();
  }
}

abstract class _DeleteRecord implements PrayerTrackerEvent {
  const factory _DeleteRecord(final DateTime date) = _$DeleteRecordImpl;

  DateTime get date;
  @JsonKey(ignore: true)
  _$$DeleteRecordImplCopyWith<_$DeleteRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PrayerTrackerState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)
        loaded,
    required TResult Function(List<DateTime> missedDates) missedDaysPrompt,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult? Function(List<DateTime> missedDates)? missedDaysPrompt,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult Function(List<DateTime> missedDates)? missedDaysPrompt,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_MissedDaysPrompt value) missedDaysPrompt,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_MissedDaysPrompt value)? missedDaysPrompt,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_MissedDaysPrompt value)? missedDaysPrompt,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayerTrackerStateCopyWith<$Res> {
  factory $PrayerTrackerStateCopyWith(
          PrayerTrackerState value, $Res Function(PrayerTrackerState) then) =
      _$PrayerTrackerStateCopyWithImpl<$Res, PrayerTrackerState>;
}

/// @nodoc
class _$PrayerTrackerStateCopyWithImpl<$Res, $Val extends PrayerTrackerState>
    implements $PrayerTrackerStateCopyWith<$Res> {
  _$PrayerTrackerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$PrayerTrackerStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'PrayerTrackerState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)
        loaded,
    required TResult Function(List<DateTime> missedDates) missedDaysPrompt,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult? Function(List<DateTime> missedDates)? missedDaysPrompt,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult Function(List<DateTime> missedDates)? missedDaysPrompt,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_MissedDaysPrompt value) missedDaysPrompt,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_MissedDaysPrompt value)? missedDaysPrompt,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_MissedDaysPrompt value)? missedDaysPrompt,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements PrayerTrackerState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {DateTime selectedDate,
      Set<Salaah> missedToday,
      Map<Salaah, MissedCounter> qadaStatus,
      Map<DateTime, DailyRecord> monthRecords,
      List<DailyRecord> history});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$PrayerTrackerStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? missedToday = null,
    Object? qadaStatus = null,
    Object? monthRecords = null,
    Object? history = null,
  }) {
    return _then(_$LoadedImpl(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      missedToday: null == missedToday
          ? _value._missedToday
          : missedToday // ignore: cast_nullable_to_non_nullable
              as Set<Salaah>,
      qadaStatus: null == qadaStatus
          ? _value._qadaStatus
          : qadaStatus // ignore: cast_nullable_to_non_nullable
              as Map<Salaah, MissedCounter>,
      monthRecords: null == monthRecords
          ? _value._monthRecords
          : monthRecords // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, DailyRecord>,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<DailyRecord>,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
      {required this.selectedDate,
      required final Set<Salaah> missedToday,
      required final Map<Salaah, MissedCounter> qadaStatus,
      required final Map<DateTime, DailyRecord> monthRecords,
      required final List<DailyRecord> history})
      : _missedToday = missedToday,
        _qadaStatus = qadaStatus,
        _monthRecords = monthRecords,
        _history = history;

  @override
  final DateTime selectedDate;
  final Set<Salaah> _missedToday;
  @override
  Set<Salaah> get missedToday {
    if (_missedToday is EqualUnmodifiableSetView) return _missedToday;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_missedToday);
  }

  final Map<Salaah, MissedCounter> _qadaStatus;
  @override
  Map<Salaah, MissedCounter> get qadaStatus {
    if (_qadaStatus is EqualUnmodifiableMapView) return _qadaStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_qadaStatus);
  }

  final Map<DateTime, DailyRecord> _monthRecords;
  @override
  Map<DateTime, DailyRecord> get monthRecords {
    if (_monthRecords is EqualUnmodifiableMapView) return _monthRecords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_monthRecords);
  }

  final List<DailyRecord> _history;
  @override
  List<DailyRecord> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'PrayerTrackerState.loaded(selectedDate: $selectedDate, missedToday: $missedToday, qadaStatus: $qadaStatus, monthRecords: $monthRecords, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality()
                .equals(other._missedToday, _missedToday) &&
            const DeepCollectionEquality()
                .equals(other._qadaStatus, _qadaStatus) &&
            const DeepCollectionEquality()
                .equals(other._monthRecords, _monthRecords) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedDate,
      const DeepCollectionEquality().hash(_missedToday),
      const DeepCollectionEquality().hash(_qadaStatus),
      const DeepCollectionEquality().hash(_monthRecords),
      const DeepCollectionEquality().hash(_history));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)
        loaded,
    required TResult Function(List<DateTime> missedDates) missedDaysPrompt,
  }) {
    return loaded(selectedDate, missedToday, qadaStatus, monthRecords, history);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult? Function(List<DateTime> missedDates)? missedDaysPrompt,
  }) {
    return loaded?.call(
        selectedDate, missedToday, qadaStatus, monthRecords, history);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult Function(List<DateTime> missedDates)? missedDaysPrompt,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
          selectedDate, missedToday, qadaStatus, monthRecords, history);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_MissedDaysPrompt value) missedDaysPrompt,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_MissedDaysPrompt value)? missedDaysPrompt,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_MissedDaysPrompt value)? missedDaysPrompt,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements PrayerTrackerState {
  const factory _Loaded(
      {required final DateTime selectedDate,
      required final Set<Salaah> missedToday,
      required final Map<Salaah, MissedCounter> qadaStatus,
      required final Map<DateTime, DailyRecord> monthRecords,
      required final List<DailyRecord> history}) = _$LoadedImpl;

  DateTime get selectedDate;
  Set<Salaah> get missedToday;
  Map<Salaah, MissedCounter> get qadaStatus;
  Map<DateTime, DailyRecord> get monthRecords;
  List<DailyRecord> get history;
  @JsonKey(ignore: true)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MissedDaysPromptImplCopyWith<$Res> {
  factory _$$MissedDaysPromptImplCopyWith(_$MissedDaysPromptImpl value,
          $Res Function(_$MissedDaysPromptImpl) then) =
      __$$MissedDaysPromptImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<DateTime> missedDates});
}

/// @nodoc
class __$$MissedDaysPromptImplCopyWithImpl<$Res>
    extends _$PrayerTrackerStateCopyWithImpl<$Res, _$MissedDaysPromptImpl>
    implements _$$MissedDaysPromptImplCopyWith<$Res> {
  __$$MissedDaysPromptImplCopyWithImpl(_$MissedDaysPromptImpl _value,
      $Res Function(_$MissedDaysPromptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? missedDates = null,
  }) {
    return _then(_$MissedDaysPromptImpl(
      missedDates: null == missedDates
          ? _value._missedDates
          : missedDates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
    ));
  }
}

/// @nodoc

class _$MissedDaysPromptImpl implements _MissedDaysPrompt {
  const _$MissedDaysPromptImpl({required final List<DateTime> missedDates})
      : _missedDates = missedDates;

  final List<DateTime> _missedDates;
  @override
  List<DateTime> get missedDates {
    if (_missedDates is EqualUnmodifiableListView) return _missedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_missedDates);
  }

  @override
  String toString() {
    return 'PrayerTrackerState.missedDaysPrompt(missedDates: $missedDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissedDaysPromptImpl &&
            const DeepCollectionEquality()
                .equals(other._missedDates, _missedDates));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_missedDates));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MissedDaysPromptImplCopyWith<_$MissedDaysPromptImpl> get copyWith =>
      __$$MissedDaysPromptImplCopyWithImpl<_$MissedDaysPromptImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)
        loaded,
    required TResult Function(List<DateTime> missedDates) missedDaysPrompt,
  }) {
    return missedDaysPrompt(missedDates);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult? Function(List<DateTime> missedDates)? missedDaysPrompt,
  }) {
    return missedDaysPrompt?.call(missedDates);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(
            DateTime selectedDate,
            Set<Salaah> missedToday,
            Map<Salaah, MissedCounter> qadaStatus,
            Map<DateTime, DailyRecord> monthRecords,
            List<DailyRecord> history)?
        loaded,
    TResult Function(List<DateTime> missedDates)? missedDaysPrompt,
    required TResult orElse(),
  }) {
    if (missedDaysPrompt != null) {
      return missedDaysPrompt(missedDates);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_MissedDaysPrompt value) missedDaysPrompt,
  }) {
    return missedDaysPrompt(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_MissedDaysPrompt value)? missedDaysPrompt,
  }) {
    return missedDaysPrompt?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_MissedDaysPrompt value)? missedDaysPrompt,
    required TResult orElse(),
  }) {
    if (missedDaysPrompt != null) {
      return missedDaysPrompt(this);
    }
    return orElse();
  }
}

abstract class _MissedDaysPrompt implements PrayerTrackerState {
  const factory _MissedDaysPrompt({required final List<DateTime> missedDates}) =
      _$MissedDaysPromptImpl;

  List<DateTime> get missedDates;
  @JsonKey(ignore: true)
  _$$MissedDaysPromptImplCopyWith<_$MissedDaysPromptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
