// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'werd_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WerdEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WerdEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WerdEvent()';
}


}

/// @nodoc
class $WerdEventCopyWith<$Res>  {
$WerdEventCopyWith(WerdEvent _, $Res Function(WerdEvent) __);
}


/// Adds pattern-matching-related methods to [WerdEvent].
extension WerdEventPatterns on WerdEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Load value)?  load,TResult Function( _SetGoal value)?  setGoal,TResult Function( _TrackItemRead value)?  trackItemRead,TResult Function( _TrackRangeRead value)?  trackRangeRead,TResult Function( _UpdateBookmark value)?  updateBookmark,TResult Function( _ProgressUpdated value)?  progressUpdated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _SetGoal() when setGoal != null:
return setGoal(_that);case _TrackItemRead() when trackItemRead != null:
return trackItemRead(_that);case _TrackRangeRead() when trackRangeRead != null:
return trackRangeRead(_that);case _UpdateBookmark() when updateBookmark != null:
return updateBookmark(_that);case _ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Load value)  load,required TResult Function( _SetGoal value)  setGoal,required TResult Function( _TrackItemRead value)  trackItemRead,required TResult Function( _TrackRangeRead value)  trackRangeRead,required TResult Function( _UpdateBookmark value)  updateBookmark,required TResult Function( _ProgressUpdated value)  progressUpdated,}){
final _that = this;
switch (_that) {
case _Load():
return load(_that);case _SetGoal():
return setGoal(_that);case _TrackItemRead():
return trackItemRead(_that);case _TrackRangeRead():
return trackRangeRead(_that);case _UpdateBookmark():
return updateBookmark(_that);case _ProgressUpdated():
return progressUpdated(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Load value)?  load,TResult? Function( _SetGoal value)?  setGoal,TResult? Function( _TrackItemRead value)?  trackItemRead,TResult? Function( _TrackRangeRead value)?  trackRangeRead,TResult? Function( _UpdateBookmark value)?  updateBookmark,TResult? Function( _ProgressUpdated value)?  progressUpdated,}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _SetGoal() when setGoal != null:
return setGoal(_that);case _TrackItemRead() when trackItemRead != null:
return trackItemRead(_that);case _TrackRangeRead() when trackRangeRead != null:
return trackRangeRead(_that);case _UpdateBookmark() when updateBookmark != null:
return updateBookmark(_that);case _ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id)?  load,TResult Function( WerdGoal goal)?  setGoal,TResult Function( int absoluteIndex)?  trackItemRead,TResult Function( int startAbsolute,  int endAbsolute)?  trackRangeRead,TResult Function( int absoluteIndex)?  updateBookmark,TResult Function( WerdProgress progress)?  progressUpdated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that.id);case _SetGoal() when setGoal != null:
return setGoal(_that.goal);case _TrackItemRead() when trackItemRead != null:
return trackItemRead(_that.absoluteIndex);case _TrackRangeRead() when trackRangeRead != null:
return trackRangeRead(_that.startAbsolute,_that.endAbsolute);case _UpdateBookmark() when updateBookmark != null:
return updateBookmark(_that.absoluteIndex);case _ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id)  load,required TResult Function( WerdGoal goal)  setGoal,required TResult Function( int absoluteIndex)  trackItemRead,required TResult Function( int startAbsolute,  int endAbsolute)  trackRangeRead,required TResult Function( int absoluteIndex)  updateBookmark,required TResult Function( WerdProgress progress)  progressUpdated,}) {final _that = this;
switch (_that) {
case _Load():
return load(_that.id);case _SetGoal():
return setGoal(_that.goal);case _TrackItemRead():
return trackItemRead(_that.absoluteIndex);case _TrackRangeRead():
return trackRangeRead(_that.startAbsolute,_that.endAbsolute);case _UpdateBookmark():
return updateBookmark(_that.absoluteIndex);case _ProgressUpdated():
return progressUpdated(_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id)?  load,TResult? Function( WerdGoal goal)?  setGoal,TResult? Function( int absoluteIndex)?  trackItemRead,TResult? Function( int startAbsolute,  int endAbsolute)?  trackRangeRead,TResult? Function( int absoluteIndex)?  updateBookmark,TResult? Function( WerdProgress progress)?  progressUpdated,}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that.id);case _SetGoal() when setGoal != null:
return setGoal(_that.goal);case _TrackItemRead() when trackItemRead != null:
return trackItemRead(_that.absoluteIndex);case _TrackRangeRead() when trackRangeRead != null:
return trackRangeRead(_that.startAbsolute,_that.endAbsolute);case _UpdateBookmark() when updateBookmark != null:
return updateBookmark(_that.absoluteIndex);case _ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that.progress);case _:
  return null;

}
}

}

/// @nodoc


class _Load implements WerdEvent {
  const _Load({this.id = 'default'});
  

@JsonKey() final  String id;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadCopyWith<_Load> get copyWith => __$LoadCopyWithImpl<_Load>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Load&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'WerdEvent.load(id: $id)';
}


}

/// @nodoc
abstract mixin class _$LoadCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$LoadCopyWith(_Load value, $Res Function(_Load) _then) = __$LoadCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$LoadCopyWithImpl<$Res>
    implements _$LoadCopyWith<$Res> {
  __$LoadCopyWithImpl(this._self, this._then);

  final _Load _self;
  final $Res Function(_Load) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_Load(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _SetGoal implements WerdEvent {
  const _SetGoal(this.goal);
  

 final  WerdGoal goal;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetGoalCopyWith<_SetGoal> get copyWith => __$SetGoalCopyWithImpl<_SetGoal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetGoal&&(identical(other.goal, goal) || other.goal == goal));
}


@override
int get hashCode => Object.hash(runtimeType,goal);

@override
String toString() {
  return 'WerdEvent.setGoal(goal: $goal)';
}


}

/// @nodoc
abstract mixin class _$SetGoalCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$SetGoalCopyWith(_SetGoal value, $Res Function(_SetGoal) _then) = __$SetGoalCopyWithImpl;
@useResult
$Res call({
 WerdGoal goal
});




}
/// @nodoc
class __$SetGoalCopyWithImpl<$Res>
    implements _$SetGoalCopyWith<$Res> {
  __$SetGoalCopyWithImpl(this._self, this._then);

  final _SetGoal _self;
  final $Res Function(_SetGoal) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? goal = null,}) {
  return _then(_SetGoal(
null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WerdGoal,
  ));
}


}

/// @nodoc


class _TrackItemRead implements WerdEvent {
  const _TrackItemRead(this.absoluteIndex);
  

 final  int absoluteIndex;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackItemReadCopyWith<_TrackItemRead> get copyWith => __$TrackItemReadCopyWithImpl<_TrackItemRead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackItemRead&&(identical(other.absoluteIndex, absoluteIndex) || other.absoluteIndex == absoluteIndex));
}


@override
int get hashCode => Object.hash(runtimeType,absoluteIndex);

@override
String toString() {
  return 'WerdEvent.trackItemRead(absoluteIndex: $absoluteIndex)';
}


}

/// @nodoc
abstract mixin class _$TrackItemReadCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$TrackItemReadCopyWith(_TrackItemRead value, $Res Function(_TrackItemRead) _then) = __$TrackItemReadCopyWithImpl;
@useResult
$Res call({
 int absoluteIndex
});




}
/// @nodoc
class __$TrackItemReadCopyWithImpl<$Res>
    implements _$TrackItemReadCopyWith<$Res> {
  __$TrackItemReadCopyWithImpl(this._self, this._then);

  final _TrackItemRead _self;
  final $Res Function(_TrackItemRead) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? absoluteIndex = null,}) {
  return _then(_TrackItemRead(
null == absoluteIndex ? _self.absoluteIndex : absoluteIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _TrackRangeRead implements WerdEvent {
  const _TrackRangeRead(this.startAbsolute, this.endAbsolute);
  

 final  int startAbsolute;
 final  int endAbsolute;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackRangeReadCopyWith<_TrackRangeRead> get copyWith => __$TrackRangeReadCopyWithImpl<_TrackRangeRead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackRangeRead&&(identical(other.startAbsolute, startAbsolute) || other.startAbsolute == startAbsolute)&&(identical(other.endAbsolute, endAbsolute) || other.endAbsolute == endAbsolute));
}


@override
int get hashCode => Object.hash(runtimeType,startAbsolute,endAbsolute);

@override
String toString() {
  return 'WerdEvent.trackRangeRead(startAbsolute: $startAbsolute, endAbsolute: $endAbsolute)';
}


}

/// @nodoc
abstract mixin class _$TrackRangeReadCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$TrackRangeReadCopyWith(_TrackRangeRead value, $Res Function(_TrackRangeRead) _then) = __$TrackRangeReadCopyWithImpl;
@useResult
$Res call({
 int startAbsolute, int endAbsolute
});




}
/// @nodoc
class __$TrackRangeReadCopyWithImpl<$Res>
    implements _$TrackRangeReadCopyWith<$Res> {
  __$TrackRangeReadCopyWithImpl(this._self, this._then);

  final _TrackRangeRead _self;
  final $Res Function(_TrackRangeRead) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startAbsolute = null,Object? endAbsolute = null,}) {
  return _then(_TrackRangeRead(
null == startAbsolute ? _self.startAbsolute : startAbsolute // ignore: cast_nullable_to_non_nullable
as int,null == endAbsolute ? _self.endAbsolute : endAbsolute // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _UpdateBookmark implements WerdEvent {
  const _UpdateBookmark(this.absoluteIndex);
  

 final  int absoluteIndex;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateBookmarkCopyWith<_UpdateBookmark> get copyWith => __$UpdateBookmarkCopyWithImpl<_UpdateBookmark>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateBookmark&&(identical(other.absoluteIndex, absoluteIndex) || other.absoluteIndex == absoluteIndex));
}


@override
int get hashCode => Object.hash(runtimeType,absoluteIndex);

@override
String toString() {
  return 'WerdEvent.updateBookmark(absoluteIndex: $absoluteIndex)';
}


}

/// @nodoc
abstract mixin class _$UpdateBookmarkCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$UpdateBookmarkCopyWith(_UpdateBookmark value, $Res Function(_UpdateBookmark) _then) = __$UpdateBookmarkCopyWithImpl;
@useResult
$Res call({
 int absoluteIndex
});




}
/// @nodoc
class __$UpdateBookmarkCopyWithImpl<$Res>
    implements _$UpdateBookmarkCopyWith<$Res> {
  __$UpdateBookmarkCopyWithImpl(this._self, this._then);

  final _UpdateBookmark _self;
  final $Res Function(_UpdateBookmark) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? absoluteIndex = null,}) {
  return _then(_UpdateBookmark(
null == absoluteIndex ? _self.absoluteIndex : absoluteIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ProgressUpdated implements WerdEvent {
  const _ProgressUpdated(this.progress);
  

 final  WerdProgress progress;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressUpdatedCopyWith<_ProgressUpdated> get copyWith => __$ProgressUpdatedCopyWithImpl<_ProgressUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressUpdated&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,progress);

@override
String toString() {
  return 'WerdEvent.progressUpdated(progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$ProgressUpdatedCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$ProgressUpdatedCopyWith(_ProgressUpdated value, $Res Function(_ProgressUpdated) _then) = __$ProgressUpdatedCopyWithImpl;
@useResult
$Res call({
 WerdProgress progress
});




}
/// @nodoc
class __$ProgressUpdatedCopyWithImpl<$Res>
    implements _$ProgressUpdatedCopyWith<$Res> {
  __$ProgressUpdatedCopyWithImpl(this._self, this._then);

  final _ProgressUpdated _self;
  final $Res Function(_ProgressUpdated) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? progress = null,}) {
  return _then(_ProgressUpdated(
null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as WerdProgress,
  ));
}


}

// dart format on
