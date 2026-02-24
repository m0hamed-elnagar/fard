// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasbih_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TasbihEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasbihEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent()';
}


}

/// @nodoc
class $TasbihEventCopyWith<$Res>  {
$TasbihEventCopyWith(TasbihEvent _, $Res Function(TasbihEvent) __);
}


/// Adds pattern-matching-related methods to [TasbihEvent].
extension TasbihEventPatterns on TasbihEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadData value)?  loadData,TResult Function( _SelectCategory value)?  selectCategory,TResult Function( _Increment value)?  increment,TResult Function( _Reset value)?  reset,TResult Function( _ToggleSound value)?  toggleSound,TResult Function( _ToggleVibration value)?  toggleVibration,TResult Function( _ToggleTranslation value)?  toggleTranslation,TResult Function( _ToggleTransliteration value)?  toggleTransliteration,TResult Function( _SelectCompletionDua value)?  selectCompletionDua,TResult Function( _RememberCompletionDua value)?  rememberCompletionDua,TResult Function( _UpdateCustomTarget value)?  updateCustomTarget,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadData() when loadData != null:
return loadData(_that);case _SelectCategory() when selectCategory != null:
return selectCategory(_that);case _Increment() when increment != null:
return increment(_that);case _Reset() when reset != null:
return reset(_that);case _ToggleSound() when toggleSound != null:
return toggleSound(_that);case _ToggleVibration() when toggleVibration != null:
return toggleVibration(_that);case _ToggleTranslation() when toggleTranslation != null:
return toggleTranslation(_that);case _ToggleTransliteration() when toggleTransliteration != null:
return toggleTransliteration(_that);case _SelectCompletionDua() when selectCompletionDua != null:
return selectCompletionDua(_that);case _RememberCompletionDua() when rememberCompletionDua != null:
return rememberCompletionDua(_that);case _UpdateCustomTarget() when updateCustomTarget != null:
return updateCustomTarget(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadData value)  loadData,required TResult Function( _SelectCategory value)  selectCategory,required TResult Function( _Increment value)  increment,required TResult Function( _Reset value)  reset,required TResult Function( _ToggleSound value)  toggleSound,required TResult Function( _ToggleVibration value)  toggleVibration,required TResult Function( _ToggleTranslation value)  toggleTranslation,required TResult Function( _ToggleTransliteration value)  toggleTransliteration,required TResult Function( _SelectCompletionDua value)  selectCompletionDua,required TResult Function( _RememberCompletionDua value)  rememberCompletionDua,required TResult Function( _UpdateCustomTarget value)  updateCustomTarget,}){
final _that = this;
switch (_that) {
case _LoadData():
return loadData(_that);case _SelectCategory():
return selectCategory(_that);case _Increment():
return increment(_that);case _Reset():
return reset(_that);case _ToggleSound():
return toggleSound(_that);case _ToggleVibration():
return toggleVibration(_that);case _ToggleTranslation():
return toggleTranslation(_that);case _ToggleTransliteration():
return toggleTransliteration(_that);case _SelectCompletionDua():
return selectCompletionDua(_that);case _RememberCompletionDua():
return rememberCompletionDua(_that);case _UpdateCustomTarget():
return updateCustomTarget(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadData value)?  loadData,TResult? Function( _SelectCategory value)?  selectCategory,TResult? Function( _Increment value)?  increment,TResult? Function( _Reset value)?  reset,TResult? Function( _ToggleSound value)?  toggleSound,TResult? Function( _ToggleVibration value)?  toggleVibration,TResult? Function( _ToggleTranslation value)?  toggleTranslation,TResult? Function( _ToggleTransliteration value)?  toggleTransliteration,TResult? Function( _SelectCompletionDua value)?  selectCompletionDua,TResult? Function( _RememberCompletionDua value)?  rememberCompletionDua,TResult? Function( _UpdateCustomTarget value)?  updateCustomTarget,}){
final _that = this;
switch (_that) {
case _LoadData() when loadData != null:
return loadData(_that);case _SelectCategory() when selectCategory != null:
return selectCategory(_that);case _Increment() when increment != null:
return increment(_that);case _Reset() when reset != null:
return reset(_that);case _ToggleSound() when toggleSound != null:
return toggleSound(_that);case _ToggleVibration() when toggleVibration != null:
return toggleVibration(_that);case _ToggleTranslation() when toggleTranslation != null:
return toggleTranslation(_that);case _ToggleTransliteration() when toggleTransliteration != null:
return toggleTransliteration(_that);case _SelectCompletionDua() when selectCompletionDua != null:
return selectCompletionDua(_that);case _RememberCompletionDua() when rememberCompletionDua != null:
return rememberCompletionDua(_that);case _UpdateCustomTarget() when updateCustomTarget != null:
return updateCustomTarget(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadData,TResult Function( String categoryId)?  selectCategory,TResult Function()?  increment,TResult Function()?  reset,TResult Function()?  toggleSound,TResult Function()?  toggleVibration,TResult Function()?  toggleTranslation,TResult Function()?  toggleTransliteration,TResult Function( String duaId)?  selectCompletionDua,TResult Function()?  rememberCompletionDua,TResult Function( int? target)?  updateCustomTarget,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadData() when loadData != null:
return loadData();case _SelectCategory() when selectCategory != null:
return selectCategory(_that.categoryId);case _Increment() when increment != null:
return increment();case _Reset() when reset != null:
return reset();case _ToggleSound() when toggleSound != null:
return toggleSound();case _ToggleVibration() when toggleVibration != null:
return toggleVibration();case _ToggleTranslation() when toggleTranslation != null:
return toggleTranslation();case _ToggleTransliteration() when toggleTransliteration != null:
return toggleTransliteration();case _SelectCompletionDua() when selectCompletionDua != null:
return selectCompletionDua(_that.duaId);case _RememberCompletionDua() when rememberCompletionDua != null:
return rememberCompletionDua();case _UpdateCustomTarget() when updateCustomTarget != null:
return updateCustomTarget(_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadData,required TResult Function( String categoryId)  selectCategory,required TResult Function()  increment,required TResult Function()  reset,required TResult Function()  toggleSound,required TResult Function()  toggleVibration,required TResult Function()  toggleTranslation,required TResult Function()  toggleTransliteration,required TResult Function( String duaId)  selectCompletionDua,required TResult Function()  rememberCompletionDua,required TResult Function( int? target)  updateCustomTarget,}) {final _that = this;
switch (_that) {
case _LoadData():
return loadData();case _SelectCategory():
return selectCategory(_that.categoryId);case _Increment():
return increment();case _Reset():
return reset();case _ToggleSound():
return toggleSound();case _ToggleVibration():
return toggleVibration();case _ToggleTranslation():
return toggleTranslation();case _ToggleTransliteration():
return toggleTransliteration();case _SelectCompletionDua():
return selectCompletionDua(_that.duaId);case _RememberCompletionDua():
return rememberCompletionDua();case _UpdateCustomTarget():
return updateCustomTarget(_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadData,TResult? Function( String categoryId)?  selectCategory,TResult? Function()?  increment,TResult? Function()?  reset,TResult? Function()?  toggleSound,TResult? Function()?  toggleVibration,TResult? Function()?  toggleTranslation,TResult? Function()?  toggleTransliteration,TResult? Function( String duaId)?  selectCompletionDua,TResult? Function()?  rememberCompletionDua,TResult? Function( int? target)?  updateCustomTarget,}) {final _that = this;
switch (_that) {
case _LoadData() when loadData != null:
return loadData();case _SelectCategory() when selectCategory != null:
return selectCategory(_that.categoryId);case _Increment() when increment != null:
return increment();case _Reset() when reset != null:
return reset();case _ToggleSound() when toggleSound != null:
return toggleSound();case _ToggleVibration() when toggleVibration != null:
return toggleVibration();case _ToggleTranslation() when toggleTranslation != null:
return toggleTranslation();case _ToggleTransliteration() when toggleTransliteration != null:
return toggleTransliteration();case _SelectCompletionDua() when selectCompletionDua != null:
return selectCompletionDua(_that.duaId);case _RememberCompletionDua() when rememberCompletionDua != null:
return rememberCompletionDua();case _UpdateCustomTarget() when updateCustomTarget != null:
return updateCustomTarget(_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _LoadData implements TasbihEvent {
  const _LoadData();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadData);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.loadData()';
}


}




/// @nodoc


class _SelectCategory implements TasbihEvent {
  const _SelectCategory(this.categoryId);
  

 final  String categoryId;

/// Create a copy of TasbihEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectCategoryCopyWith<_SelectCategory> get copyWith => __$SelectCategoryCopyWithImpl<_SelectCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId);

@override
String toString() {
  return 'TasbihEvent.selectCategory(categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$SelectCategoryCopyWith<$Res> implements $TasbihEventCopyWith<$Res> {
  factory _$SelectCategoryCopyWith(_SelectCategory value, $Res Function(_SelectCategory) _then) = __$SelectCategoryCopyWithImpl;
@useResult
$Res call({
 String categoryId
});




}
/// @nodoc
class __$SelectCategoryCopyWithImpl<$Res>
    implements _$SelectCategoryCopyWith<$Res> {
  __$SelectCategoryCopyWithImpl(this._self, this._then);

  final _SelectCategory _self;
  final $Res Function(_SelectCategory) _then;

/// Create a copy of TasbihEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categoryId = null,}) {
  return _then(_SelectCategory(
null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Increment implements TasbihEvent {
  const _Increment();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Increment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.increment()';
}


}




/// @nodoc


class _Reset implements TasbihEvent {
  const _Reset();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.reset()';
}


}




/// @nodoc


class _ToggleSound implements TasbihEvent {
  const _ToggleSound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleSound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.toggleSound()';
}


}




/// @nodoc


class _ToggleVibration implements TasbihEvent {
  const _ToggleVibration();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleVibration);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.toggleVibration()';
}


}




/// @nodoc


class _ToggleTranslation implements TasbihEvent {
  const _ToggleTranslation();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleTranslation);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.toggleTranslation()';
}


}




/// @nodoc


class _ToggleTransliteration implements TasbihEvent {
  const _ToggleTransliteration();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleTransliteration);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.toggleTransliteration()';
}


}




/// @nodoc


class _SelectCompletionDua implements TasbihEvent {
  const _SelectCompletionDua(this.duaId);
  

 final  String duaId;

/// Create a copy of TasbihEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectCompletionDuaCopyWith<_SelectCompletionDua> get copyWith => __$SelectCompletionDuaCopyWithImpl<_SelectCompletionDua>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectCompletionDua&&(identical(other.duaId, duaId) || other.duaId == duaId));
}


@override
int get hashCode => Object.hash(runtimeType,duaId);

@override
String toString() {
  return 'TasbihEvent.selectCompletionDua(duaId: $duaId)';
}


}

/// @nodoc
abstract mixin class _$SelectCompletionDuaCopyWith<$Res> implements $TasbihEventCopyWith<$Res> {
  factory _$SelectCompletionDuaCopyWith(_SelectCompletionDua value, $Res Function(_SelectCompletionDua) _then) = __$SelectCompletionDuaCopyWithImpl;
@useResult
$Res call({
 String duaId
});




}
/// @nodoc
class __$SelectCompletionDuaCopyWithImpl<$Res>
    implements _$SelectCompletionDuaCopyWith<$Res> {
  __$SelectCompletionDuaCopyWithImpl(this._self, this._then);

  final _SelectCompletionDua _self;
  final $Res Function(_SelectCompletionDua) _then;

/// Create a copy of TasbihEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? duaId = null,}) {
  return _then(_SelectCompletionDua(
null == duaId ? _self.duaId : duaId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _RememberCompletionDua implements TasbihEvent {
  const _RememberCompletionDua();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RememberCompletionDua);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TasbihEvent.rememberCompletionDua()';
}


}




/// @nodoc


class _UpdateCustomTarget implements TasbihEvent {
  const _UpdateCustomTarget(this.target);
  

 final  int? target;

/// Create a copy of TasbihEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCustomTargetCopyWith<_UpdateCustomTarget> get copyWith => __$UpdateCustomTargetCopyWithImpl<_UpdateCustomTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCustomTarget&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,target);

@override
String toString() {
  return 'TasbihEvent.updateCustomTarget(target: $target)';
}


}

/// @nodoc
abstract mixin class _$UpdateCustomTargetCopyWith<$Res> implements $TasbihEventCopyWith<$Res> {
  factory _$UpdateCustomTargetCopyWith(_UpdateCustomTarget value, $Res Function(_UpdateCustomTarget) _then) = __$UpdateCustomTargetCopyWithImpl;
@useResult
$Res call({
 int? target
});




}
/// @nodoc
class __$UpdateCustomTargetCopyWithImpl<$Res>
    implements _$UpdateCustomTargetCopyWith<$Res> {
  __$UpdateCustomTargetCopyWithImpl(this._self, this._then);

  final _UpdateCustomTarget _self;
  final $Res Function(_UpdateCustomTarget) _then;

/// Create a copy of TasbihEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = freezed,}) {
  return _then(_UpdateCustomTarget(
freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$TasbihState {

 TasbihData get data; TasbihCategory get currentCategory; CompletionDua? get currentCompletionDua; int get totalCount; int get currentCycleCount; int get currentCycleIndex; bool get showCompletionDua; bool get isLoading; String? get error; bool get duaRemembered; int? get customTasbihTarget;
/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasbihStateCopyWith<TasbihState> get copyWith => _$TasbihStateCopyWithImpl<TasbihState>(this as TasbihState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasbihState&&(identical(other.data, data) || other.data == data)&&(identical(other.currentCategory, currentCategory) || other.currentCategory == currentCategory)&&(identical(other.currentCompletionDua, currentCompletionDua) || other.currentCompletionDua == currentCompletionDua)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.currentCycleCount, currentCycleCount) || other.currentCycleCount == currentCycleCount)&&(identical(other.currentCycleIndex, currentCycleIndex) || other.currentCycleIndex == currentCycleIndex)&&(identical(other.showCompletionDua, showCompletionDua) || other.showCompletionDua == showCompletionDua)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.duaRemembered, duaRemembered) || other.duaRemembered == duaRemembered)&&(identical(other.customTasbihTarget, customTasbihTarget) || other.customTasbihTarget == customTasbihTarget));
}


@override
int get hashCode => Object.hash(runtimeType,data,currentCategory,currentCompletionDua,totalCount,currentCycleCount,currentCycleIndex,showCompletionDua,isLoading,error,duaRemembered,customTasbihTarget);

@override
String toString() {
  return 'TasbihState(data: $data, currentCategory: $currentCategory, currentCompletionDua: $currentCompletionDua, totalCount: $totalCount, currentCycleCount: $currentCycleCount, currentCycleIndex: $currentCycleIndex, showCompletionDua: $showCompletionDua, isLoading: $isLoading, error: $error, duaRemembered: $duaRemembered, customTasbihTarget: $customTasbihTarget)';
}


}

/// @nodoc
abstract mixin class $TasbihStateCopyWith<$Res>  {
  factory $TasbihStateCopyWith(TasbihState value, $Res Function(TasbihState) _then) = _$TasbihStateCopyWithImpl;
@useResult
$Res call({
 TasbihData data, TasbihCategory currentCategory, CompletionDua? currentCompletionDua, int totalCount, int currentCycleCount, int currentCycleIndex, bool showCompletionDua, bool isLoading, String? error, bool duaRemembered, int? customTasbihTarget
});


$TasbihDataCopyWith<$Res> get data;$TasbihCategoryCopyWith<$Res> get currentCategory;$CompletionDuaCopyWith<$Res>? get currentCompletionDua;

}
/// @nodoc
class _$TasbihStateCopyWithImpl<$Res>
    implements $TasbihStateCopyWith<$Res> {
  _$TasbihStateCopyWithImpl(this._self, this._then);

  final TasbihState _self;
  final $Res Function(TasbihState) _then;

/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? currentCategory = null,Object? currentCompletionDua = freezed,Object? totalCount = null,Object? currentCycleCount = null,Object? currentCycleIndex = null,Object? showCompletionDua = null,Object? isLoading = null,Object? error = freezed,Object? duaRemembered = null,Object? customTasbihTarget = freezed,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TasbihData,currentCategory: null == currentCategory ? _self.currentCategory : currentCategory // ignore: cast_nullable_to_non_nullable
as TasbihCategory,currentCompletionDua: freezed == currentCompletionDua ? _self.currentCompletionDua : currentCompletionDua // ignore: cast_nullable_to_non_nullable
as CompletionDua?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,currentCycleCount: null == currentCycleCount ? _self.currentCycleCount : currentCycleCount // ignore: cast_nullable_to_non_nullable
as int,currentCycleIndex: null == currentCycleIndex ? _self.currentCycleIndex : currentCycleIndex // ignore: cast_nullable_to_non_nullable
as int,showCompletionDua: null == showCompletionDua ? _self.showCompletionDua : showCompletionDua // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,duaRemembered: null == duaRemembered ? _self.duaRemembered : duaRemembered // ignore: cast_nullable_to_non_nullable
as bool,customTasbihTarget: freezed == customTasbihTarget ? _self.customTasbihTarget : customTasbihTarget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TasbihDataCopyWith<$Res> get data {
  
  return $TasbihDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TasbihCategoryCopyWith<$Res> get currentCategory {
  
  return $TasbihCategoryCopyWith<$Res>(_self.currentCategory, (value) {
    return _then(_self.copyWith(currentCategory: value));
  });
}/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompletionDuaCopyWith<$Res>? get currentCompletionDua {
    if (_self.currentCompletionDua == null) {
    return null;
  }

  return $CompletionDuaCopyWith<$Res>(_self.currentCompletionDua!, (value) {
    return _then(_self.copyWith(currentCompletionDua: value));
  });
}
}


/// Adds pattern-matching-related methods to [TasbihState].
extension TasbihStatePatterns on TasbihState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasbihState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasbihState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasbihState value)  $default,){
final _that = this;
switch (_that) {
case _TasbihState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasbihState value)?  $default,){
final _that = this;
switch (_that) {
case _TasbihState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TasbihData data,  TasbihCategory currentCategory,  CompletionDua? currentCompletionDua,  int totalCount,  int currentCycleCount,  int currentCycleIndex,  bool showCompletionDua,  bool isLoading,  String? error,  bool duaRemembered,  int? customTasbihTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasbihState() when $default != null:
return $default(_that.data,_that.currentCategory,_that.currentCompletionDua,_that.totalCount,_that.currentCycleCount,_that.currentCycleIndex,_that.showCompletionDua,_that.isLoading,_that.error,_that.duaRemembered,_that.customTasbihTarget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TasbihData data,  TasbihCategory currentCategory,  CompletionDua? currentCompletionDua,  int totalCount,  int currentCycleCount,  int currentCycleIndex,  bool showCompletionDua,  bool isLoading,  String? error,  bool duaRemembered,  int? customTasbihTarget)  $default,) {final _that = this;
switch (_that) {
case _TasbihState():
return $default(_that.data,_that.currentCategory,_that.currentCompletionDua,_that.totalCount,_that.currentCycleCount,_that.currentCycleIndex,_that.showCompletionDua,_that.isLoading,_that.error,_that.duaRemembered,_that.customTasbihTarget);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TasbihData data,  TasbihCategory currentCategory,  CompletionDua? currentCompletionDua,  int totalCount,  int currentCycleCount,  int currentCycleIndex,  bool showCompletionDua,  bool isLoading,  String? error,  bool duaRemembered,  int? customTasbihTarget)?  $default,) {final _that = this;
switch (_that) {
case _TasbihState() when $default != null:
return $default(_that.data,_that.currentCategory,_that.currentCompletionDua,_that.totalCount,_that.currentCycleCount,_that.currentCycleIndex,_that.showCompletionDua,_that.isLoading,_that.error,_that.duaRemembered,_that.customTasbihTarget);case _:
  return null;

}
}

}

/// @nodoc


class _TasbihState implements TasbihState {
  const _TasbihState({required this.data, required this.currentCategory, this.currentCompletionDua, this.totalCount = 0, this.currentCycleCount = 0, this.currentCycleIndex = 0, this.showCompletionDua = false, this.isLoading = false, this.error, this.duaRemembered = false, this.customTasbihTarget});
  

@override final  TasbihData data;
@override final  TasbihCategory currentCategory;
@override final  CompletionDua? currentCompletionDua;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  int currentCycleCount;
@override@JsonKey() final  int currentCycleIndex;
@override@JsonKey() final  bool showCompletionDua;
@override@JsonKey() final  bool isLoading;
@override final  String? error;
@override@JsonKey() final  bool duaRemembered;
@override final  int? customTasbihTarget;

/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasbihStateCopyWith<_TasbihState> get copyWith => __$TasbihStateCopyWithImpl<_TasbihState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasbihState&&(identical(other.data, data) || other.data == data)&&(identical(other.currentCategory, currentCategory) || other.currentCategory == currentCategory)&&(identical(other.currentCompletionDua, currentCompletionDua) || other.currentCompletionDua == currentCompletionDua)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.currentCycleCount, currentCycleCount) || other.currentCycleCount == currentCycleCount)&&(identical(other.currentCycleIndex, currentCycleIndex) || other.currentCycleIndex == currentCycleIndex)&&(identical(other.showCompletionDua, showCompletionDua) || other.showCompletionDua == showCompletionDua)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.duaRemembered, duaRemembered) || other.duaRemembered == duaRemembered)&&(identical(other.customTasbihTarget, customTasbihTarget) || other.customTasbihTarget == customTasbihTarget));
}


@override
int get hashCode => Object.hash(runtimeType,data,currentCategory,currentCompletionDua,totalCount,currentCycleCount,currentCycleIndex,showCompletionDua,isLoading,error,duaRemembered,customTasbihTarget);

@override
String toString() {
  return 'TasbihState(data: $data, currentCategory: $currentCategory, currentCompletionDua: $currentCompletionDua, totalCount: $totalCount, currentCycleCount: $currentCycleCount, currentCycleIndex: $currentCycleIndex, showCompletionDua: $showCompletionDua, isLoading: $isLoading, error: $error, duaRemembered: $duaRemembered, customTasbihTarget: $customTasbihTarget)';
}


}

/// @nodoc
abstract mixin class _$TasbihStateCopyWith<$Res> implements $TasbihStateCopyWith<$Res> {
  factory _$TasbihStateCopyWith(_TasbihState value, $Res Function(_TasbihState) _then) = __$TasbihStateCopyWithImpl;
@override @useResult
$Res call({
 TasbihData data, TasbihCategory currentCategory, CompletionDua? currentCompletionDua, int totalCount, int currentCycleCount, int currentCycleIndex, bool showCompletionDua, bool isLoading, String? error, bool duaRemembered, int? customTasbihTarget
});


@override $TasbihDataCopyWith<$Res> get data;@override $TasbihCategoryCopyWith<$Res> get currentCategory;@override $CompletionDuaCopyWith<$Res>? get currentCompletionDua;

}
/// @nodoc
class __$TasbihStateCopyWithImpl<$Res>
    implements _$TasbihStateCopyWith<$Res> {
  __$TasbihStateCopyWithImpl(this._self, this._then);

  final _TasbihState _self;
  final $Res Function(_TasbihState) _then;

/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? currentCategory = null,Object? currentCompletionDua = freezed,Object? totalCount = null,Object? currentCycleCount = null,Object? currentCycleIndex = null,Object? showCompletionDua = null,Object? isLoading = null,Object? error = freezed,Object? duaRemembered = null,Object? customTasbihTarget = freezed,}) {
  return _then(_TasbihState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TasbihData,currentCategory: null == currentCategory ? _self.currentCategory : currentCategory // ignore: cast_nullable_to_non_nullable
as TasbihCategory,currentCompletionDua: freezed == currentCompletionDua ? _self.currentCompletionDua : currentCompletionDua // ignore: cast_nullable_to_non_nullable
as CompletionDua?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,currentCycleCount: null == currentCycleCount ? _self.currentCycleCount : currentCycleCount // ignore: cast_nullable_to_non_nullable
as int,currentCycleIndex: null == currentCycleIndex ? _self.currentCycleIndex : currentCycleIndex // ignore: cast_nullable_to_non_nullable
as int,showCompletionDua: null == showCompletionDua ? _self.showCompletionDua : showCompletionDua // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,duaRemembered: null == duaRemembered ? _self.duaRemembered : duaRemembered // ignore: cast_nullable_to_non_nullable
as bool,customTasbihTarget: freezed == customTasbihTarget ? _self.customTasbihTarget : customTasbihTarget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TasbihDataCopyWith<$Res> get data {
  
  return $TasbihDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TasbihCategoryCopyWith<$Res> get currentCategory {
  
  return $TasbihCategoryCopyWith<$Res>(_self.currentCategory, (value) {
    return _then(_self.copyWith(currentCategory: value));
  });
}/// Create a copy of TasbihState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompletionDuaCopyWith<$Res>? get currentCompletionDua {
    if (_self.currentCompletionDua == null) {
    return null;
  }

  return $CompletionDuaCopyWith<$Res>(_self.currentCompletionDua!, (value) {
    return _then(_self.copyWith(currentCompletionDua: value));
  });
}
}

// dart format on
