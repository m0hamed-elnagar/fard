// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'azkar_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AzkarEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AzkarEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AzkarEvent()';
}


}

/// @nodoc
class $AzkarEventCopyWith<$Res>  {
$AzkarEventCopyWith(AzkarEvent _, $Res Function(AzkarEvent) __);
}


/// Adds pattern-matching-related methods to [AzkarEvent].
extension AzkarEventPatterns on AzkarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadCategories value)?  loadCategories,TResult Function( _LoadAzkar value)?  loadAzkar,TResult Function( _IncrementCount value)?  incrementCount,TResult Function( _ResetCategory value)?  resetCategory,TResult Function( _ResetItem value)?  resetItem,TResult Function( _ResetAll value)?  resetAll,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadCategories() when loadCategories != null:
return loadCategories(_that);case _LoadAzkar() when loadAzkar != null:
return loadAzkar(_that);case _IncrementCount() when incrementCount != null:
return incrementCount(_that);case _ResetCategory() when resetCategory != null:
return resetCategory(_that);case _ResetItem() when resetItem != null:
return resetItem(_that);case _ResetAll() when resetAll != null:
return resetAll(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadCategories value)  loadCategories,required TResult Function( _LoadAzkar value)  loadAzkar,required TResult Function( _IncrementCount value)  incrementCount,required TResult Function( _ResetCategory value)  resetCategory,required TResult Function( _ResetItem value)  resetItem,required TResult Function( _ResetAll value)  resetAll,}){
final _that = this;
switch (_that) {
case _LoadCategories():
return loadCategories(_that);case _LoadAzkar():
return loadAzkar(_that);case _IncrementCount():
return incrementCount(_that);case _ResetCategory():
return resetCategory(_that);case _ResetItem():
return resetItem(_that);case _ResetAll():
return resetAll(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadCategories value)?  loadCategories,TResult? Function( _LoadAzkar value)?  loadAzkar,TResult? Function( _IncrementCount value)?  incrementCount,TResult? Function( _ResetCategory value)?  resetCategory,TResult? Function( _ResetItem value)?  resetItem,TResult? Function( _ResetAll value)?  resetAll,}){
final _that = this;
switch (_that) {
case _LoadCategories() when loadCategories != null:
return loadCategories(_that);case _LoadAzkar() when loadAzkar != null:
return loadAzkar(_that);case _IncrementCount() when incrementCount != null:
return incrementCount(_that);case _ResetCategory() when resetCategory != null:
return resetCategory(_that);case _ResetItem() when resetItem != null:
return resetItem(_that);case _ResetAll() when resetAll != null:
return resetAll(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadCategories,TResult Function( String category)?  loadAzkar,TResult Function( int index)?  incrementCount,TResult Function( String category)?  resetCategory,TResult Function( int index)?  resetItem,TResult Function()?  resetAll,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadCategories() when loadCategories != null:
return loadCategories();case _LoadAzkar() when loadAzkar != null:
return loadAzkar(_that.category);case _IncrementCount() when incrementCount != null:
return incrementCount(_that.index);case _ResetCategory() when resetCategory != null:
return resetCategory(_that.category);case _ResetItem() when resetItem != null:
return resetItem(_that.index);case _ResetAll() when resetAll != null:
return resetAll();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadCategories,required TResult Function( String category)  loadAzkar,required TResult Function( int index)  incrementCount,required TResult Function( String category)  resetCategory,required TResult Function( int index)  resetItem,required TResult Function()  resetAll,}) {final _that = this;
switch (_that) {
case _LoadCategories():
return loadCategories();case _LoadAzkar():
return loadAzkar(_that.category);case _IncrementCount():
return incrementCount(_that.index);case _ResetCategory():
return resetCategory(_that.category);case _ResetItem():
return resetItem(_that.index);case _ResetAll():
return resetAll();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadCategories,TResult? Function( String category)?  loadAzkar,TResult? Function( int index)?  incrementCount,TResult? Function( String category)?  resetCategory,TResult? Function( int index)?  resetItem,TResult? Function()?  resetAll,}) {final _that = this;
switch (_that) {
case _LoadCategories() when loadCategories != null:
return loadCategories();case _LoadAzkar() when loadAzkar != null:
return loadAzkar(_that.category);case _IncrementCount() when incrementCount != null:
return incrementCount(_that.index);case _ResetCategory() when resetCategory != null:
return resetCategory(_that.category);case _ResetItem() when resetItem != null:
return resetItem(_that.index);case _ResetAll() when resetAll != null:
return resetAll();case _:
  return null;

}
}

}

/// @nodoc


class _LoadCategories implements AzkarEvent {
  const _LoadCategories();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadCategories);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AzkarEvent.loadCategories()';
}


}




/// @nodoc


class _LoadAzkar implements AzkarEvent {
  const _LoadAzkar(this.category);
  

 final  String category;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadAzkarCopyWith<_LoadAzkar> get copyWith => __$LoadAzkarCopyWithImpl<_LoadAzkar>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadAzkar&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,category);

@override
String toString() {
  return 'AzkarEvent.loadAzkar(category: $category)';
}


}

/// @nodoc
abstract mixin class _$LoadAzkarCopyWith<$Res> implements $AzkarEventCopyWith<$Res> {
  factory _$LoadAzkarCopyWith(_LoadAzkar value, $Res Function(_LoadAzkar) _then) = __$LoadAzkarCopyWithImpl;
@useResult
$Res call({
 String category
});




}
/// @nodoc
class __$LoadAzkarCopyWithImpl<$Res>
    implements _$LoadAzkarCopyWith<$Res> {
  __$LoadAzkarCopyWithImpl(this._self, this._then);

  final _LoadAzkar _self;
  final $Res Function(_LoadAzkar) _then;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? category = null,}) {
  return _then(_LoadAzkar(
null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _IncrementCount implements AzkarEvent {
  const _IncrementCount(this.index);
  

 final  int index;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncrementCountCopyWith<_IncrementCount> get copyWith => __$IncrementCountCopyWithImpl<_IncrementCount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncrementCount&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,index);

@override
String toString() {
  return 'AzkarEvent.incrementCount(index: $index)';
}


}

/// @nodoc
abstract mixin class _$IncrementCountCopyWith<$Res> implements $AzkarEventCopyWith<$Res> {
  factory _$IncrementCountCopyWith(_IncrementCount value, $Res Function(_IncrementCount) _then) = __$IncrementCountCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class __$IncrementCountCopyWithImpl<$Res>
    implements _$IncrementCountCopyWith<$Res> {
  __$IncrementCountCopyWithImpl(this._self, this._then);

  final _IncrementCount _self;
  final $Res Function(_IncrementCount) _then;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(_IncrementCount(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ResetCategory implements AzkarEvent {
  const _ResetCategory(this.category);
  

 final  String category;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetCategoryCopyWith<_ResetCategory> get copyWith => __$ResetCategoryCopyWithImpl<_ResetCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetCategory&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,category);

@override
String toString() {
  return 'AzkarEvent.resetCategory(category: $category)';
}


}

/// @nodoc
abstract mixin class _$ResetCategoryCopyWith<$Res> implements $AzkarEventCopyWith<$Res> {
  factory _$ResetCategoryCopyWith(_ResetCategory value, $Res Function(_ResetCategory) _then) = __$ResetCategoryCopyWithImpl;
@useResult
$Res call({
 String category
});




}
/// @nodoc
class __$ResetCategoryCopyWithImpl<$Res>
    implements _$ResetCategoryCopyWith<$Res> {
  __$ResetCategoryCopyWithImpl(this._self, this._then);

  final _ResetCategory _self;
  final $Res Function(_ResetCategory) _then;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? category = null,}) {
  return _then(_ResetCategory(
null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ResetItem implements AzkarEvent {
  const _ResetItem(this.index);
  

 final  int index;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetItemCopyWith<_ResetItem> get copyWith => __$ResetItemCopyWithImpl<_ResetItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetItem&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,index);

@override
String toString() {
  return 'AzkarEvent.resetItem(index: $index)';
}


}

/// @nodoc
abstract mixin class _$ResetItemCopyWith<$Res> implements $AzkarEventCopyWith<$Res> {
  factory _$ResetItemCopyWith(_ResetItem value, $Res Function(_ResetItem) _then) = __$ResetItemCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class __$ResetItemCopyWithImpl<$Res>
    implements _$ResetItemCopyWith<$Res> {
  __$ResetItemCopyWithImpl(this._self, this._then);

  final _ResetItem _self;
  final $Res Function(_ResetItem) _then;

/// Create a copy of AzkarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(_ResetItem(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ResetAll implements AzkarEvent {
  const _ResetAll();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetAll);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AzkarEvent.resetAll()';
}


}




/// @nodoc
mixin _$AzkarState {

 bool get isLoading; List<String> get categories; List<AzkarItem> get azkar; String? get currentCategory; String? get error;
/// Create a copy of AzkarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AzkarStateCopyWith<AzkarState> get copyWith => _$AzkarStateCopyWithImpl<AzkarState>(this as AzkarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AzkarState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.azkar, azkar)&&(identical(other.currentCategory, currentCategory) || other.currentCategory == currentCategory)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(azkar),currentCategory,error);

@override
String toString() {
  return 'AzkarState(isLoading: $isLoading, categories: $categories, azkar: $azkar, currentCategory: $currentCategory, error: $error)';
}


}

/// @nodoc
abstract mixin class $AzkarStateCopyWith<$Res>  {
  factory $AzkarStateCopyWith(AzkarState value, $Res Function(AzkarState) _then) = _$AzkarStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<String> categories, List<AzkarItem> azkar, String? currentCategory, String? error
});




}
/// @nodoc
class _$AzkarStateCopyWithImpl<$Res>
    implements $AzkarStateCopyWith<$Res> {
  _$AzkarStateCopyWithImpl(this._self, this._then);

  final AzkarState _self;
  final $Res Function(AzkarState) _then;

/// Create a copy of AzkarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? categories = null,Object? azkar = null,Object? currentCategory = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,azkar: null == azkar ? _self.azkar : azkar // ignore: cast_nullable_to_non_nullable
as List<AzkarItem>,currentCategory: freezed == currentCategory ? _self.currentCategory : currentCategory // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AzkarState].
extension AzkarStatePatterns on AzkarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AzkarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AzkarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AzkarState value)  $default,){
final _that = this;
switch (_that) {
case _AzkarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AzkarState value)?  $default,){
final _that = this;
switch (_that) {
case _AzkarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<String> categories,  List<AzkarItem> azkar,  String? currentCategory,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AzkarState() when $default != null:
return $default(_that.isLoading,_that.categories,_that.azkar,_that.currentCategory,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<String> categories,  List<AzkarItem> azkar,  String? currentCategory,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AzkarState():
return $default(_that.isLoading,_that.categories,_that.azkar,_that.currentCategory,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<String> categories,  List<AzkarItem> azkar,  String? currentCategory,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AzkarState() when $default != null:
return $default(_that.isLoading,_that.categories,_that.azkar,_that.currentCategory,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AzkarState implements AzkarState {
  const _AzkarState({this.isLoading = false, final  List<String> categories = const [], final  List<AzkarItem> azkar = const [], this.currentCategory, this.error}): _categories = categories,_azkar = azkar;
  

@override@JsonKey() final  bool isLoading;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<AzkarItem> _azkar;
@override@JsonKey() List<AzkarItem> get azkar {
  if (_azkar is EqualUnmodifiableListView) return _azkar;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_azkar);
}

@override final  String? currentCategory;
@override final  String? error;

/// Create a copy of AzkarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AzkarStateCopyWith<_AzkarState> get copyWith => __$AzkarStateCopyWithImpl<_AzkarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AzkarState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._azkar, _azkar)&&(identical(other.currentCategory, currentCategory) || other.currentCategory == currentCategory)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_azkar),currentCategory,error);

@override
String toString() {
  return 'AzkarState(isLoading: $isLoading, categories: $categories, azkar: $azkar, currentCategory: $currentCategory, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AzkarStateCopyWith<$Res> implements $AzkarStateCopyWith<$Res> {
  factory _$AzkarStateCopyWith(_AzkarState value, $Res Function(_AzkarState) _then) = __$AzkarStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<String> categories, List<AzkarItem> azkar, String? currentCategory, String? error
});




}
/// @nodoc
class __$AzkarStateCopyWithImpl<$Res>
    implements _$AzkarStateCopyWith<$Res> {
  __$AzkarStateCopyWithImpl(this._self, this._then);

  final _AzkarState _self;
  final $Res Function(_AzkarState) _then;

/// Create a copy of AzkarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? categories = null,Object? azkar = null,Object? currentCategory = freezed,Object? error = freezed,}) {
  return _then(_AzkarState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,azkar: null == azkar ? _self._azkar : azkar // ignore: cast_nullable_to_non_nullable
as List<AzkarItem>,currentCategory: freezed == currentCategory ? _self.currentCategory : currentCategory // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
