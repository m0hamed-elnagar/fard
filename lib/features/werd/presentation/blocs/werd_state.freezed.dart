// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'werd_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
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


class _WerdState extends WerdState {
  const _WerdState({this.isLoading = false, this.goal, this.progress, this.error}): super._();
  

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
