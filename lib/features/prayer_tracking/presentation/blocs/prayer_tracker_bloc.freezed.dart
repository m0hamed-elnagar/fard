// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_tracker_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrayerTrackerEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerTrackerEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrayerTrackerEvent()';
}


}

/// @nodoc
class $PrayerTrackerEventCopyWith<$Res>  {
$PrayerTrackerEventCopyWith(PrayerTrackerEvent _, $Res Function(PrayerTrackerEvent) __);
}


/// Adds pattern-matching-related methods to [PrayerTrackerEvent].
extension PrayerTrackerEventPatterns on PrayerTrackerEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Load value)?  load,TResult Function( _TogglePrayer value)?  togglePrayer,TResult Function( _AddQada value)?  addQada,TResult Function( _RemoveQada value)?  removeQada,TResult Function( _Save value)?  save,TResult Function( _LoadMonth value)?  loadMonth,TResult Function( _CheckMissedDays value)?  checkMissedDays,TResult Function( _AcknowledgeMissedDays value)?  acknowledgeMissedDays,TResult Function( _BulkAddQada value)?  bulkAddQada,TResult Function( _UpdateQada value)?  updateQada,TResult Function( _DeleteRecord value)?  deleteRecord,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _TogglePrayer() when togglePrayer != null:
return togglePrayer(_that);case _AddQada() when addQada != null:
return addQada(_that);case _RemoveQada() when removeQada != null:
return removeQada(_that);case _Save() when save != null:
return save(_that);case _LoadMonth() when loadMonth != null:
return loadMonth(_that);case _CheckMissedDays() when checkMissedDays != null:
return checkMissedDays(_that);case _AcknowledgeMissedDays() when acknowledgeMissedDays != null:
return acknowledgeMissedDays(_that);case _BulkAddQada() when bulkAddQada != null:
return bulkAddQada(_that);case _UpdateQada() when updateQada != null:
return updateQada(_that);case _DeleteRecord() when deleteRecord != null:
return deleteRecord(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Load value)  load,required TResult Function( _TogglePrayer value)  togglePrayer,required TResult Function( _AddQada value)  addQada,required TResult Function( _RemoveQada value)  removeQada,required TResult Function( _Save value)  save,required TResult Function( _LoadMonth value)  loadMonth,required TResult Function( _CheckMissedDays value)  checkMissedDays,required TResult Function( _AcknowledgeMissedDays value)  acknowledgeMissedDays,required TResult Function( _BulkAddQada value)  bulkAddQada,required TResult Function( _UpdateQada value)  updateQada,required TResult Function( _DeleteRecord value)  deleteRecord,}){
final _that = this;
switch (_that) {
case _Load():
return load(_that);case _TogglePrayer():
return togglePrayer(_that);case _AddQada():
return addQada(_that);case _RemoveQada():
return removeQada(_that);case _Save():
return save(_that);case _LoadMonth():
return loadMonth(_that);case _CheckMissedDays():
return checkMissedDays(_that);case _AcknowledgeMissedDays():
return acknowledgeMissedDays(_that);case _BulkAddQada():
return bulkAddQada(_that);case _UpdateQada():
return updateQada(_that);case _DeleteRecord():
return deleteRecord(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Load value)?  load,TResult? Function( _TogglePrayer value)?  togglePrayer,TResult? Function( _AddQada value)?  addQada,TResult? Function( _RemoveQada value)?  removeQada,TResult? Function( _Save value)?  save,TResult? Function( _LoadMonth value)?  loadMonth,TResult? Function( _CheckMissedDays value)?  checkMissedDays,TResult? Function( _AcknowledgeMissedDays value)?  acknowledgeMissedDays,TResult? Function( _BulkAddQada value)?  bulkAddQada,TResult? Function( _UpdateQada value)?  updateQada,TResult? Function( _DeleteRecord value)?  deleteRecord,}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _TogglePrayer() when togglePrayer != null:
return togglePrayer(_that);case _AddQada() when addQada != null:
return addQada(_that);case _RemoveQada() when removeQada != null:
return removeQada(_that);case _Save() when save != null:
return save(_that);case _LoadMonth() when loadMonth != null:
return loadMonth(_that);case _CheckMissedDays() when checkMissedDays != null:
return checkMissedDays(_that);case _AcknowledgeMissedDays() when acknowledgeMissedDays != null:
return acknowledgeMissedDays(_that);case _BulkAddQada() when bulkAddQada != null:
return bulkAddQada(_that);case _UpdateQada() when updateQada != null:
return updateQada(_that);case _DeleteRecord() when deleteRecord != null:
return deleteRecord(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime date)?  load,TResult Function( Salaah prayer)?  togglePrayer,TResult Function( Salaah prayer)?  addQada,TResult Function( Salaah prayer)?  removeQada,TResult Function()?  save,TResult Function( int year,  int month)?  loadMonth,TResult Function()?  checkMissedDays,TResult Function( List<DateTime> selectedDates)?  acknowledgeMissedDays,TResult Function( Map<Salaah, int> counts)?  bulkAddQada,TResult Function( Map<Salaah, int> counts)?  updateQada,TResult Function( DateTime date)?  deleteRecord,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that.date);case _TogglePrayer() when togglePrayer != null:
return togglePrayer(_that.prayer);case _AddQada() when addQada != null:
return addQada(_that.prayer);case _RemoveQada() when removeQada != null:
return removeQada(_that.prayer);case _Save() when save != null:
return save();case _LoadMonth() when loadMonth != null:
return loadMonth(_that.year,_that.month);case _CheckMissedDays() when checkMissedDays != null:
return checkMissedDays();case _AcknowledgeMissedDays() when acknowledgeMissedDays != null:
return acknowledgeMissedDays(_that.selectedDates);case _BulkAddQada() when bulkAddQada != null:
return bulkAddQada(_that.counts);case _UpdateQada() when updateQada != null:
return updateQada(_that.counts);case _DeleteRecord() when deleteRecord != null:
return deleteRecord(_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime date)  load,required TResult Function( Salaah prayer)  togglePrayer,required TResult Function( Salaah prayer)  addQada,required TResult Function( Salaah prayer)  removeQada,required TResult Function()  save,required TResult Function( int year,  int month)  loadMonth,required TResult Function()  checkMissedDays,required TResult Function( List<DateTime> selectedDates)  acknowledgeMissedDays,required TResult Function( Map<Salaah, int> counts)  bulkAddQada,required TResult Function( Map<Salaah, int> counts)  updateQada,required TResult Function( DateTime date)  deleteRecord,}) {final _that = this;
switch (_that) {
case _Load():
return load(_that.date);case _TogglePrayer():
return togglePrayer(_that.prayer);case _AddQada():
return addQada(_that.prayer);case _RemoveQada():
return removeQada(_that.prayer);case _Save():
return save();case _LoadMonth():
return loadMonth(_that.year,_that.month);case _CheckMissedDays():
return checkMissedDays();case _AcknowledgeMissedDays():
return acknowledgeMissedDays(_that.selectedDates);case _BulkAddQada():
return bulkAddQada(_that.counts);case _UpdateQada():
return updateQada(_that.counts);case _DeleteRecord():
return deleteRecord(_that.date);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime date)?  load,TResult? Function( Salaah prayer)?  togglePrayer,TResult? Function( Salaah prayer)?  addQada,TResult? Function( Salaah prayer)?  removeQada,TResult? Function()?  save,TResult? Function( int year,  int month)?  loadMonth,TResult? Function()?  checkMissedDays,TResult? Function( List<DateTime> selectedDates)?  acknowledgeMissedDays,TResult? Function( Map<Salaah, int> counts)?  bulkAddQada,TResult? Function( Map<Salaah, int> counts)?  updateQada,TResult? Function( DateTime date)?  deleteRecord,}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that.date);case _TogglePrayer() when togglePrayer != null:
return togglePrayer(_that.prayer);case _AddQada() when addQada != null:
return addQada(_that.prayer);case _RemoveQada() when removeQada != null:
return removeQada(_that.prayer);case _Save() when save != null:
return save();case _LoadMonth() when loadMonth != null:
return loadMonth(_that.year,_that.month);case _CheckMissedDays() when checkMissedDays != null:
return checkMissedDays();case _AcknowledgeMissedDays() when acknowledgeMissedDays != null:
return acknowledgeMissedDays(_that.selectedDates);case _BulkAddQada() when bulkAddQada != null:
return bulkAddQada(_that.counts);case _UpdateQada() when updateQada != null:
return updateQada(_that.counts);case _DeleteRecord() when deleteRecord != null:
return deleteRecord(_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _Load implements PrayerTrackerEvent {
  const _Load(this.date);
  

 final  DateTime date;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadCopyWith<_Load> get copyWith => __$LoadCopyWithImpl<_Load>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Load&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,date);

@override
String toString() {
  return 'PrayerTrackerEvent.load(date: $date)';
}


}

/// @nodoc
abstract mixin class _$LoadCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$LoadCopyWith(_Load value, $Res Function(_Load) _then) = __$LoadCopyWithImpl;
@useResult
$Res call({
 DateTime date
});




}
/// @nodoc
class __$LoadCopyWithImpl<$Res>
    implements _$LoadCopyWith<$Res> {
  __$LoadCopyWithImpl(this._self, this._then);

  final _Load _self;
  final $Res Function(_Load) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = null,}) {
  return _then(_Load(
null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _TogglePrayer implements PrayerTrackerEvent {
  const _TogglePrayer(this.prayer);
  

 final  Salaah prayer;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TogglePrayerCopyWith<_TogglePrayer> get copyWith => __$TogglePrayerCopyWithImpl<_TogglePrayer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TogglePrayer&&(identical(other.prayer, prayer) || other.prayer == prayer));
}


@override
int get hashCode => Object.hash(runtimeType,prayer);

@override
String toString() {
  return 'PrayerTrackerEvent.togglePrayer(prayer: $prayer)';
}


}

/// @nodoc
abstract mixin class _$TogglePrayerCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$TogglePrayerCopyWith(_TogglePrayer value, $Res Function(_TogglePrayer) _then) = __$TogglePrayerCopyWithImpl;
@useResult
$Res call({
 Salaah prayer
});




}
/// @nodoc
class __$TogglePrayerCopyWithImpl<$Res>
    implements _$TogglePrayerCopyWith<$Res> {
  __$TogglePrayerCopyWithImpl(this._self, this._then);

  final _TogglePrayer _self;
  final $Res Function(_TogglePrayer) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prayer = null,}) {
  return _then(_TogglePrayer(
null == prayer ? _self.prayer : prayer // ignore: cast_nullable_to_non_nullable
as Salaah,
  ));
}


}

/// @nodoc


class _AddQada implements PrayerTrackerEvent {
  const _AddQada(this.prayer);
  

 final  Salaah prayer;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddQadaCopyWith<_AddQada> get copyWith => __$AddQadaCopyWithImpl<_AddQada>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddQada&&(identical(other.prayer, prayer) || other.prayer == prayer));
}


@override
int get hashCode => Object.hash(runtimeType,prayer);

@override
String toString() {
  return 'PrayerTrackerEvent.addQada(prayer: $prayer)';
}


}

/// @nodoc
abstract mixin class _$AddQadaCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$AddQadaCopyWith(_AddQada value, $Res Function(_AddQada) _then) = __$AddQadaCopyWithImpl;
@useResult
$Res call({
 Salaah prayer
});




}
/// @nodoc
class __$AddQadaCopyWithImpl<$Res>
    implements _$AddQadaCopyWith<$Res> {
  __$AddQadaCopyWithImpl(this._self, this._then);

  final _AddQada _self;
  final $Res Function(_AddQada) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prayer = null,}) {
  return _then(_AddQada(
null == prayer ? _self.prayer : prayer // ignore: cast_nullable_to_non_nullable
as Salaah,
  ));
}


}

/// @nodoc


class _RemoveQada implements PrayerTrackerEvent {
  const _RemoveQada(this.prayer);
  

 final  Salaah prayer;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoveQadaCopyWith<_RemoveQada> get copyWith => __$RemoveQadaCopyWithImpl<_RemoveQada>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoveQada&&(identical(other.prayer, prayer) || other.prayer == prayer));
}


@override
int get hashCode => Object.hash(runtimeType,prayer);

@override
String toString() {
  return 'PrayerTrackerEvent.removeQada(prayer: $prayer)';
}


}

/// @nodoc
abstract mixin class _$RemoveQadaCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$RemoveQadaCopyWith(_RemoveQada value, $Res Function(_RemoveQada) _then) = __$RemoveQadaCopyWithImpl;
@useResult
$Res call({
 Salaah prayer
});




}
/// @nodoc
class __$RemoveQadaCopyWithImpl<$Res>
    implements _$RemoveQadaCopyWith<$Res> {
  __$RemoveQadaCopyWithImpl(this._self, this._then);

  final _RemoveQada _self;
  final $Res Function(_RemoveQada) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prayer = null,}) {
  return _then(_RemoveQada(
null == prayer ? _self.prayer : prayer // ignore: cast_nullable_to_non_nullable
as Salaah,
  ));
}


}

/// @nodoc


class _Save implements PrayerTrackerEvent {
  const _Save();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Save);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrayerTrackerEvent.save()';
}


}




/// @nodoc


class _LoadMonth implements PrayerTrackerEvent {
  const _LoadMonth(this.year, this.month);
  

 final  int year;
 final  int month;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadMonthCopyWith<_LoadMonth> get copyWith => __$LoadMonthCopyWithImpl<_LoadMonth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadMonth&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month));
}


@override
int get hashCode => Object.hash(runtimeType,year,month);

@override
String toString() {
  return 'PrayerTrackerEvent.loadMonth(year: $year, month: $month)';
}


}

/// @nodoc
abstract mixin class _$LoadMonthCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$LoadMonthCopyWith(_LoadMonth value, $Res Function(_LoadMonth) _then) = __$LoadMonthCopyWithImpl;
@useResult
$Res call({
 int year, int month
});




}
/// @nodoc
class __$LoadMonthCopyWithImpl<$Res>
    implements _$LoadMonthCopyWith<$Res> {
  __$LoadMonthCopyWithImpl(this._self, this._then);

  final _LoadMonth _self;
  final $Res Function(_LoadMonth) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,}) {
  return _then(_LoadMonth(
null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _CheckMissedDays implements PrayerTrackerEvent {
  const _CheckMissedDays();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckMissedDays);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrayerTrackerEvent.checkMissedDays()';
}


}




/// @nodoc


class _AcknowledgeMissedDays implements PrayerTrackerEvent {
  const _AcknowledgeMissedDays({required final  List<DateTime> selectedDates}): _selectedDates = selectedDates;
  

 final  List<DateTime> _selectedDates;
 List<DateTime> get selectedDates {
  if (_selectedDates is EqualUnmodifiableListView) return _selectedDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedDates);
}


/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcknowledgeMissedDaysCopyWith<_AcknowledgeMissedDays> get copyWith => __$AcknowledgeMissedDaysCopyWithImpl<_AcknowledgeMissedDays>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcknowledgeMissedDays&&const DeepCollectionEquality().equals(other._selectedDates, _selectedDates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedDates));

@override
String toString() {
  return 'PrayerTrackerEvent.acknowledgeMissedDays(selectedDates: $selectedDates)';
}


}

/// @nodoc
abstract mixin class _$AcknowledgeMissedDaysCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$AcknowledgeMissedDaysCopyWith(_AcknowledgeMissedDays value, $Res Function(_AcknowledgeMissedDays) _then) = __$AcknowledgeMissedDaysCopyWithImpl;
@useResult
$Res call({
 List<DateTime> selectedDates
});




}
/// @nodoc
class __$AcknowledgeMissedDaysCopyWithImpl<$Res>
    implements _$AcknowledgeMissedDaysCopyWith<$Res> {
  __$AcknowledgeMissedDaysCopyWithImpl(this._self, this._then);

  final _AcknowledgeMissedDays _self;
  final $Res Function(_AcknowledgeMissedDays) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedDates = null,}) {
  return _then(_AcknowledgeMissedDays(
selectedDates: null == selectedDates ? _self._selectedDates : selectedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,
  ));
}


}

/// @nodoc


class _BulkAddQada implements PrayerTrackerEvent {
  const _BulkAddQada(final  Map<Salaah, int> counts): _counts = counts;
  

 final  Map<Salaah, int> _counts;
 Map<Salaah, int> get counts {
  if (_counts is EqualUnmodifiableMapView) return _counts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_counts);
}


/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkAddQadaCopyWith<_BulkAddQada> get copyWith => __$BulkAddQadaCopyWithImpl<_BulkAddQada>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkAddQada&&const DeepCollectionEquality().equals(other._counts, _counts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_counts));

@override
String toString() {
  return 'PrayerTrackerEvent.bulkAddQada(counts: $counts)';
}


}

/// @nodoc
abstract mixin class _$BulkAddQadaCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$BulkAddQadaCopyWith(_BulkAddQada value, $Res Function(_BulkAddQada) _then) = __$BulkAddQadaCopyWithImpl;
@useResult
$Res call({
 Map<Salaah, int> counts
});




}
/// @nodoc
class __$BulkAddQadaCopyWithImpl<$Res>
    implements _$BulkAddQadaCopyWith<$Res> {
  __$BulkAddQadaCopyWithImpl(this._self, this._then);

  final _BulkAddQada _self;
  final $Res Function(_BulkAddQada) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? counts = null,}) {
  return _then(_BulkAddQada(
null == counts ? _self._counts : counts // ignore: cast_nullable_to_non_nullable
as Map<Salaah, int>,
  ));
}


}

/// @nodoc


class _UpdateQada implements PrayerTrackerEvent {
  const _UpdateQada(final  Map<Salaah, int> counts): _counts = counts;
  

 final  Map<Salaah, int> _counts;
 Map<Salaah, int> get counts {
  if (_counts is EqualUnmodifiableMapView) return _counts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_counts);
}


/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateQadaCopyWith<_UpdateQada> get copyWith => __$UpdateQadaCopyWithImpl<_UpdateQada>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateQada&&const DeepCollectionEquality().equals(other._counts, _counts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_counts));

@override
String toString() {
  return 'PrayerTrackerEvent.updateQada(counts: $counts)';
}


}

/// @nodoc
abstract mixin class _$UpdateQadaCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$UpdateQadaCopyWith(_UpdateQada value, $Res Function(_UpdateQada) _then) = __$UpdateQadaCopyWithImpl;
@useResult
$Res call({
 Map<Salaah, int> counts
});




}
/// @nodoc
class __$UpdateQadaCopyWithImpl<$Res>
    implements _$UpdateQadaCopyWith<$Res> {
  __$UpdateQadaCopyWithImpl(this._self, this._then);

  final _UpdateQada _self;
  final $Res Function(_UpdateQada) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? counts = null,}) {
  return _then(_UpdateQada(
null == counts ? _self._counts : counts // ignore: cast_nullable_to_non_nullable
as Map<Salaah, int>,
  ));
}


}

/// @nodoc


class _DeleteRecord implements PrayerTrackerEvent {
  const _DeleteRecord(this.date);
  

 final  DateTime date;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteRecordCopyWith<_DeleteRecord> get copyWith => __$DeleteRecordCopyWithImpl<_DeleteRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteRecord&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,date);

@override
String toString() {
  return 'PrayerTrackerEvent.deleteRecord(date: $date)';
}


}

/// @nodoc
abstract mixin class _$DeleteRecordCopyWith<$Res> implements $PrayerTrackerEventCopyWith<$Res> {
  factory _$DeleteRecordCopyWith(_DeleteRecord value, $Res Function(_DeleteRecord) _then) = __$DeleteRecordCopyWithImpl;
@useResult
$Res call({
 DateTime date
});




}
/// @nodoc
class __$DeleteRecordCopyWithImpl<$Res>
    implements _$DeleteRecordCopyWith<$Res> {
  __$DeleteRecordCopyWithImpl(this._self, this._then);

  final _DeleteRecord _self;
  final $Res Function(_DeleteRecord) _then;

/// Create a copy of PrayerTrackerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = null,}) {
  return _then(_DeleteRecord(
null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PrayerTrackerState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerTrackerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrayerTrackerState()';
}


}

/// @nodoc
class $PrayerTrackerStateCopyWith<$Res>  {
$PrayerTrackerStateCopyWith(PrayerTrackerState _, $Res Function(PrayerTrackerState) __);
}


/// Adds pattern-matching-related methods to [PrayerTrackerState].
extension PrayerTrackerStatePatterns on PrayerTrackerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _MissedDaysPrompt value)?  missedDaysPrompt,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _MissedDaysPrompt() when missedDaysPrompt != null:
return missedDaysPrompt(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _MissedDaysPrompt value)  missedDaysPrompt,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _MissedDaysPrompt():
return missedDaysPrompt(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _MissedDaysPrompt value)?  missedDaysPrompt,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _MissedDaysPrompt() when missedDaysPrompt != null:
return missedDaysPrompt(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( DateTime selectedDate,  Set<Salaah> missedToday,  Map<Salaah, MissedCounter> qadaStatus,  Map<DateTime, DailyRecord> monthRecords,  List<DailyRecord> history)?  loaded,TResult Function( List<DateTime> missedDates)?  missedDaysPrompt,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.selectedDate,_that.missedToday,_that.qadaStatus,_that.monthRecords,_that.history);case _MissedDaysPrompt() when missedDaysPrompt != null:
return missedDaysPrompt(_that.missedDates);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( DateTime selectedDate,  Set<Salaah> missedToday,  Map<Salaah, MissedCounter> qadaStatus,  Map<DateTime, DailyRecord> monthRecords,  List<DailyRecord> history)  loaded,required TResult Function( List<DateTime> missedDates)  missedDaysPrompt,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Loading():
return loading();case _Loaded():
return loaded(_that.selectedDate,_that.missedToday,_that.qadaStatus,_that.monthRecords,_that.history);case _MissedDaysPrompt():
return missedDaysPrompt(_that.missedDates);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( DateTime selectedDate,  Set<Salaah> missedToday,  Map<Salaah, MissedCounter> qadaStatus,  Map<DateTime, DailyRecord> monthRecords,  List<DailyRecord> history)?  loaded,TResult? Function( List<DateTime> missedDates)?  missedDaysPrompt,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.selectedDate,_that.missedToday,_that.qadaStatus,_that.monthRecords,_that.history);case _MissedDaysPrompt() when missedDaysPrompt != null:
return missedDaysPrompt(_that.missedDates);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Loading implements PrayerTrackerState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrayerTrackerState.loading()';
}


}




/// @nodoc


class _Loaded implements PrayerTrackerState {
  const _Loaded({required this.selectedDate, required final  Set<Salaah> missedToday, required final  Map<Salaah, MissedCounter> qadaStatus, required final  Map<DateTime, DailyRecord> monthRecords, required final  List<DailyRecord> history}): _missedToday = missedToday,_qadaStatus = qadaStatus,_monthRecords = monthRecords,_history = history;
  

 final  DateTime selectedDate;
 final  Set<Salaah> _missedToday;
 Set<Salaah> get missedToday {
  if (_missedToday is EqualUnmodifiableSetView) return _missedToday;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_missedToday);
}

 final  Map<Salaah, MissedCounter> _qadaStatus;
 Map<Salaah, MissedCounter> get qadaStatus {
  if (_qadaStatus is EqualUnmodifiableMapView) return _qadaStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_qadaStatus);
}

 final  Map<DateTime, DailyRecord> _monthRecords;
 Map<DateTime, DailyRecord> get monthRecords {
  if (_monthRecords is EqualUnmodifiableMapView) return _monthRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_monthRecords);
}

 final  List<DailyRecord> _history;
 List<DailyRecord> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of PrayerTrackerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&const DeepCollectionEquality().equals(other._missedToday, _missedToday)&&const DeepCollectionEquality().equals(other._qadaStatus, _qadaStatus)&&const DeepCollectionEquality().equals(other._monthRecords, _monthRecords)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,const DeepCollectionEquality().hash(_missedToday),const DeepCollectionEquality().hash(_qadaStatus),const DeepCollectionEquality().hash(_monthRecords),const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'PrayerTrackerState.loaded(selectedDate: $selectedDate, missedToday: $missedToday, qadaStatus: $qadaStatus, monthRecords: $monthRecords, history: $history)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $PrayerTrackerStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 DateTime selectedDate, Set<Salaah> missedToday, Map<Salaah, MissedCounter> qadaStatus, Map<DateTime, DailyRecord> monthRecords, List<DailyRecord> history
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of PrayerTrackerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedDate = null,Object? missedToday = null,Object? qadaStatus = null,Object? monthRecords = null,Object? history = null,}) {
  return _then(_Loaded(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,missedToday: null == missedToday ? _self._missedToday : missedToday // ignore: cast_nullable_to_non_nullable
as Set<Salaah>,qadaStatus: null == qadaStatus ? _self._qadaStatus : qadaStatus // ignore: cast_nullable_to_non_nullable
as Map<Salaah, MissedCounter>,monthRecords: null == monthRecords ? _self._monthRecords : monthRecords // ignore: cast_nullable_to_non_nullable
as Map<DateTime, DailyRecord>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<DailyRecord>,
  ));
}


}

/// @nodoc


class _MissedDaysPrompt implements PrayerTrackerState {
  const _MissedDaysPrompt({required final  List<DateTime> missedDates}): _missedDates = missedDates;
  

 final  List<DateTime> _missedDates;
 List<DateTime> get missedDates {
  if (_missedDates is EqualUnmodifiableListView) return _missedDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missedDates);
}


/// Create a copy of PrayerTrackerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissedDaysPromptCopyWith<_MissedDaysPrompt> get copyWith => __$MissedDaysPromptCopyWithImpl<_MissedDaysPrompt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissedDaysPrompt&&const DeepCollectionEquality().equals(other._missedDates, _missedDates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_missedDates));

@override
String toString() {
  return 'PrayerTrackerState.missedDaysPrompt(missedDates: $missedDates)';
}


}

/// @nodoc
abstract mixin class _$MissedDaysPromptCopyWith<$Res> implements $PrayerTrackerStateCopyWith<$Res> {
  factory _$MissedDaysPromptCopyWith(_MissedDaysPrompt value, $Res Function(_MissedDaysPrompt) _then) = __$MissedDaysPromptCopyWithImpl;
@useResult
$Res call({
 List<DateTime> missedDates
});




}
/// @nodoc
class __$MissedDaysPromptCopyWithImpl<$Res>
    implements _$MissedDaysPromptCopyWith<$Res> {
  __$MissedDaysPromptCopyWithImpl(this._self, this._then);

  final _MissedDaysPrompt _self;
  final $Res Function(_MissedDaysPrompt) _then;

/// Create a copy of PrayerTrackerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? missedDates = null,}) {
  return _then(_MissedDaysPrompt(
missedDates: null == missedDates ? _self._missedDates : missedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,
  ));
}


}

/// @nodoc


class _Error implements PrayerTrackerState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of PrayerTrackerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PrayerTrackerState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PrayerTrackerStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of PrayerTrackerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
