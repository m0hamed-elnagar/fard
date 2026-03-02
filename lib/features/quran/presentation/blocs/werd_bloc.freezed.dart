// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'werd_bloc.dart';

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Load value)?  load,TResult Function( _SetGoal value)?  setGoal,TResult Function( _TrackAyahRead value)?  trackAyahRead,TResult Function( _ProgressUpdated value)?  progressUpdated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _SetGoal() when setGoal != null:
return setGoal(_that);case _TrackAyahRead() when trackAyahRead != null:
return trackAyahRead(_that);case _ProgressUpdated() when progressUpdated != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Load value)  load,required TResult Function( _SetGoal value)  setGoal,required TResult Function( _TrackAyahRead value)  trackAyahRead,required TResult Function( _ProgressUpdated value)  progressUpdated,}){
final _that = this;
switch (_that) {
case _Load():
return load(_that);case _SetGoal():
return setGoal(_that);case _TrackAyahRead():
return trackAyahRead(_that);case _ProgressUpdated():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Load value)?  load,TResult? Function( _SetGoal value)?  setGoal,TResult? Function( _TrackAyahRead value)?  trackAyahRead,TResult? Function( _ProgressUpdated value)?  progressUpdated,}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _SetGoal() when setGoal != null:
return setGoal(_that);case _TrackAyahRead() when trackAyahRead != null:
return trackAyahRead(_that);case _ProgressUpdated() when progressUpdated != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( WerdGoal goal)?  setGoal,TResult Function( AyahNumber ayah)?  trackAyahRead,TResult Function( WerdProgress progress)?  progressUpdated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load();case _SetGoal() when setGoal != null:
return setGoal(_that.goal);case _TrackAyahRead() when trackAyahRead != null:
return trackAyahRead(_that.ayah);case _ProgressUpdated() when progressUpdated != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( WerdGoal goal)  setGoal,required TResult Function( AyahNumber ayah)  trackAyahRead,required TResult Function( WerdProgress progress)  progressUpdated,}) {final _that = this;
switch (_that) {
case _Load():
return load();case _SetGoal():
return setGoal(_that.goal);case _TrackAyahRead():
return trackAyahRead(_that.ayah);case _ProgressUpdated():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( WerdGoal goal)?  setGoal,TResult? Function( AyahNumber ayah)?  trackAyahRead,TResult? Function( WerdProgress progress)?  progressUpdated,}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load();case _SetGoal() when setGoal != null:
return setGoal(_that.goal);case _TrackAyahRead() when trackAyahRead != null:
return trackAyahRead(_that.ayah);case _ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that.progress);case _:
  return null;

}
}

}

/// @nodoc


class _Load implements WerdEvent {
  const _Load();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Load);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WerdEvent.load()';
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


class _TrackAyahRead implements WerdEvent {
  const _TrackAyahRead(this.ayah);
  

 final  AyahNumber ayah;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackAyahReadCopyWith<_TrackAyahRead> get copyWith => __$TrackAyahReadCopyWithImpl<_TrackAyahRead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackAyahRead&&(identical(other.ayah, ayah) || other.ayah == ayah));
}


@override
int get hashCode => Object.hash(runtimeType,ayah);

@override
String toString() {
  return 'WerdEvent.trackAyahRead(ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$TrackAyahReadCopyWith<$Res> implements $WerdEventCopyWith<$Res> {
  factory _$TrackAyahReadCopyWith(_TrackAyahRead value, $Res Function(_TrackAyahRead) _then) = __$TrackAyahReadCopyWithImpl;
@useResult
$Res call({
 AyahNumber ayah
});




}
/// @nodoc
class __$TrackAyahReadCopyWithImpl<$Res>
    implements _$TrackAyahReadCopyWith<$Res> {
  __$TrackAyahReadCopyWithImpl(this._self, this._then);

  final _TrackAyahRead _self;
  final $Res Function(_TrackAyahRead) _then;

/// Create a copy of WerdEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ayah = null,}) {
  return _then(_TrackAyahRead(
null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as AyahNumber,
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

/// @nodoc
mixin _$WerdState {

 bool get isLoading; WerdGoal? get goal; WerdProgress? get progress; String? get error;
/// Create a copy of WerdState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WerdStateCopyWith<WerdState> get copyWith => _$WerdStateCopyWithImpl<WerdState>(this as WerdState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WerdState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,goal,progress,error);

@override
String toString() {
  return 'WerdState(isLoading: $isLoading, goal: $goal, progress: $progress, error: $error)';
}


}

/// @nodoc
abstract mixin class $WerdStateCopyWith<$Res>  {
  factory $WerdStateCopyWith(WerdState value, $Res Function(WerdState) _then) = _$WerdStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, WerdGoal? goal, WerdProgress? progress, String? error
});




}
/// @nodoc
class _$WerdStateCopyWithImpl<$Res>
    implements $WerdStateCopyWith<$Res> {
  _$WerdStateCopyWithImpl(this._self, this._then);

  final WerdState _self;
  final $Res Function(WerdState) _then;

/// Create a copy of WerdState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? goal = freezed,Object? progress = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WerdGoal?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as WerdProgress?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WerdState].
extension WerdStatePatterns on WerdState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WerdState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WerdState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WerdState value)  $default,){
final _that = this;
switch (_that) {
case _WerdState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WerdState value)?  $default,){
final _that = this;
switch (_that) {
case _WerdState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  WerdGoal? goal,  WerdProgress? progress,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WerdState() when $default != null:
return $default(_that.isLoading,_that.goal,_that.progress,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  WerdGoal? goal,  WerdProgress? progress,  String? error)  $default,) {final _that = this;
switch (_that) {
case _WerdState():
return $default(_that.isLoading,_that.goal,_that.progress,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  WerdGoal? goal,  WerdProgress? progress,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _WerdState() when $default != null:
return $default(_that.isLoading,_that.goal,_that.progress,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _WerdState implements WerdState {
  const _WerdState({this.isLoading = false, this.goal, this.progress, this.error});
  

@override@JsonKey() final  bool isLoading;
@override final  WerdGoal? goal;
@override final  WerdProgress? progress;
@override final  String? error;

/// Create a copy of WerdState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WerdStateCopyWith<_WerdState> get copyWith => __$WerdStateCopyWithImpl<_WerdState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WerdState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,goal,progress,error);

@override
String toString() {
  return 'WerdState(isLoading: $isLoading, goal: $goal, progress: $progress, error: $error)';
}


}

/// @nodoc
abstract mixin class _$WerdStateCopyWith<$Res> implements $WerdStateCopyWith<$Res> {
  factory _$WerdStateCopyWith(_WerdState value, $Res Function(_WerdState) _then) = __$WerdStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, WerdGoal? goal, WerdProgress? progress, String? error
});




}
/// @nodoc
class __$WerdStateCopyWithImpl<$Res>
    implements _$WerdStateCopyWith<$Res> {
  __$WerdStateCopyWithImpl(this._self, this._then);

  final _WerdState _self;
  final $Res Function(_WerdState) _then;

/// Create a copy of WerdState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? goal = freezed,Object? progress = freezed,Object? error = freezed,}) {
  return _then(_WerdState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WerdGoal?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as WerdProgress?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
