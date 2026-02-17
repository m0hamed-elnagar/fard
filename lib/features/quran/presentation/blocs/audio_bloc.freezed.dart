// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioEvent()';
}


}

/// @nodoc
class $AudioEventCopyWith<$Res>  {
$AudioEventCopyWith(AudioEvent _, $Res Function(AudioEvent) __);
}


/// Adds pattern-matching-related methods to [AudioEvent].
extension AudioEventPatterns on AudioEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Play value)?  play,TResult Function( _Pause value)?  pause,TResult Function( _Resume value)?  resume,TResult Function( _Stop value)?  stop,TResult Function( _StatusChanged value)?  statusChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Play() when play != null:
return play(_that);case _Pause() when pause != null:
return pause(_that);case _Resume() when resume != null:
return resume(_that);case _Stop() when stop != null:
return stop(_that);case _StatusChanged() when statusChanged != null:
return statusChanged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Play value)  play,required TResult Function( _Pause value)  pause,required TResult Function( _Resume value)  resume,required TResult Function( _Stop value)  stop,required TResult Function( _StatusChanged value)  statusChanged,}){
final _that = this;
switch (_that) {
case _Play():
return play(_that);case _Pause():
return pause(_that);case _Resume():
return resume(_that);case _Stop():
return stop(_that);case _StatusChanged():
return statusChanged(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Play value)?  play,TResult? Function( _Pause value)?  pause,TResult? Function( _Resume value)?  resume,TResult? Function( _Stop value)?  stop,TResult? Function( _StatusChanged value)?  statusChanged,}){
final _that = this;
switch (_that) {
case _Play() when play != null:
return play(_that);case _Pause() when pause != null:
return pause(_that);case _Resume() when resume != null:
return resume(_that);case _Stop() when stop != null:
return stop(_that);case _StatusChanged() when statusChanged != null:
return statusChanged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AyahNumber ayah,  String reciterId,  String? audioUrl,  AudioPlayMode mode)?  play,TResult Function()?  pause,TResult Function()?  resume,TResult Function()?  stop,TResult Function( AudioStatus status)?  statusChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Play() when play != null:
return play(_that.ayah,_that.reciterId,_that.audioUrl,_that.mode);case _Pause() when pause != null:
return pause();case _Resume() when resume != null:
return resume();case _Stop() when stop != null:
return stop();case _StatusChanged() when statusChanged != null:
return statusChanged(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AyahNumber ayah,  String reciterId,  String? audioUrl,  AudioPlayMode mode)  play,required TResult Function()  pause,required TResult Function()  resume,required TResult Function()  stop,required TResult Function( AudioStatus status)  statusChanged,}) {final _that = this;
switch (_that) {
case _Play():
return play(_that.ayah,_that.reciterId,_that.audioUrl,_that.mode);case _Pause():
return pause();case _Resume():
return resume();case _Stop():
return stop();case _StatusChanged():
return statusChanged(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AyahNumber ayah,  String reciterId,  String? audioUrl,  AudioPlayMode mode)?  play,TResult? Function()?  pause,TResult? Function()?  resume,TResult? Function()?  stop,TResult? Function( AudioStatus status)?  statusChanged,}) {final _that = this;
switch (_that) {
case _Play() when play != null:
return play(_that.ayah,_that.reciterId,_that.audioUrl,_that.mode);case _Pause() when pause != null:
return pause();case _Resume() when resume != null:
return resume();case _Stop() when stop != null:
return stop();case _StatusChanged() when statusChanged != null:
return statusChanged(_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Play implements AudioEvent {
  const _Play({required this.ayah, required this.reciterId, this.audioUrl, this.mode = AudioPlayMode.surah});
  

 final  AyahNumber ayah;
 final  String reciterId;
 final  String? audioUrl;
@JsonKey() final  AudioPlayMode mode;

/// Create a copy of AudioEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayCopyWith<_Play> get copyWith => __$PlayCopyWithImpl<_Play>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Play&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.reciterId, reciterId) || other.reciterId == reciterId)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,ayah,reciterId,audioUrl,mode);

@override
String toString() {
  return 'AudioEvent.play(ayah: $ayah, reciterId: $reciterId, audioUrl: $audioUrl, mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$PlayCopyWith<$Res> implements $AudioEventCopyWith<$Res> {
  factory _$PlayCopyWith(_Play value, $Res Function(_Play) _then) = __$PlayCopyWithImpl;
@useResult
$Res call({
 AyahNumber ayah, String reciterId, String? audioUrl, AudioPlayMode mode
});




}
/// @nodoc
class __$PlayCopyWithImpl<$Res>
    implements _$PlayCopyWith<$Res> {
  __$PlayCopyWithImpl(this._self, this._then);

  final _Play _self;
  final $Res Function(_Play) _then;

/// Create a copy of AudioEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ayah = null,Object? reciterId = null,Object? audioUrl = freezed,Object? mode = null,}) {
  return _then(_Play(
ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as AyahNumber,reciterId: null == reciterId ? _self.reciterId : reciterId // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AudioPlayMode,
  ));
}


}

/// @nodoc


class _Pause implements AudioEvent {
  const _Pause();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pause);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioEvent.pause()';
}


}




/// @nodoc


class _Resume implements AudioEvent {
  const _Resume();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Resume);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioEvent.resume()';
}


}




/// @nodoc


class _Stop implements AudioEvent {
  const _Stop();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stop);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioEvent.stop()';
}


}




/// @nodoc


class _StatusChanged implements AudioEvent {
  const _StatusChanged(this.status);
  

 final  AudioStatus status;

/// Create a copy of AudioEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusChangedCopyWith<_StatusChanged> get copyWith => __$StatusChangedCopyWithImpl<_StatusChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusChanged&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'AudioEvent.statusChanged(status: $status)';
}


}

/// @nodoc
abstract mixin class _$StatusChangedCopyWith<$Res> implements $AudioEventCopyWith<$Res> {
  factory _$StatusChangedCopyWith(_StatusChanged value, $Res Function(_StatusChanged) _then) = __$StatusChangedCopyWithImpl;
@useResult
$Res call({
 AudioStatus status
});




}
/// @nodoc
class __$StatusChangedCopyWithImpl<$Res>
    implements _$StatusChangedCopyWith<$Res> {
  __$StatusChangedCopyWithImpl(this._self, this._then);

  final _StatusChanged _self;
  final $Res Function(_StatusChanged) _then;

/// Create a copy of AudioEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_StatusChanged(
null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioStatus,
  ));
}


}

/// @nodoc
mixin _$AudioState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioState()';
}


}

/// @nodoc
class $AudioStateCopyWith<$Res>  {
$AudioStateCopyWith(AudioState _, $Res Function(AudioState) __);
}


/// Adds pattern-matching-related methods to [AudioState].
extension AudioStatePatterns on AudioState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AudioStatus status)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.status);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AudioStatus status)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.status);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AudioStatus status)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.status);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AudioState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioState.initial()';
}


}




/// @nodoc


class _Loading implements AudioState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AudioState.loading()';
}


}




/// @nodoc


class _Loaded implements AudioState {
  const _Loaded({required this.status});
  

 final  AudioStatus status;

/// Create a copy of AudioState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'AudioState.loaded(status: $status)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $AudioStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 AudioStatus status
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of AudioState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_Loaded(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AudioStatus,
  ));
}


}

/// @nodoc


class _Error implements AudioState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of AudioState
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
  return 'AudioState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $AudioStateCopyWith<$Res> {
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

/// Create a copy of AudioState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
