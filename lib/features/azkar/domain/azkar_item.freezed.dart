// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'azkar_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AzkarItem {

 String get category; String get zekr; String get description; int get count; String get reference; int get currentCount;
/// Create a copy of AzkarItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AzkarItemCopyWith<AzkarItem> get copyWith => _$AzkarItemCopyWithImpl<AzkarItem>(this as AzkarItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AzkarItem&&(identical(other.category, category) || other.category == category)&&(identical(other.zekr, zekr) || other.zekr == zekr)&&(identical(other.description, description) || other.description == description)&&(identical(other.count, count) || other.count == count)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.currentCount, currentCount) || other.currentCount == currentCount));
}


@override
int get hashCode => Object.hash(runtimeType,category,zekr,description,count,reference,currentCount);

@override
String toString() {
  return 'AzkarItem(category: $category, zekr: $zekr, description: $description, count: $count, reference: $reference, currentCount: $currentCount)';
}


}

/// @nodoc
abstract mixin class $AzkarItemCopyWith<$Res>  {
  factory $AzkarItemCopyWith(AzkarItem value, $Res Function(AzkarItem) _then) = _$AzkarItemCopyWithImpl;
@useResult
$Res call({
 String category, String zekr, String description, int count, String reference, int currentCount
});




}
/// @nodoc
class _$AzkarItemCopyWithImpl<$Res>
    implements $AzkarItemCopyWith<$Res> {
  _$AzkarItemCopyWithImpl(this._self, this._then);

  final AzkarItem _self;
  final $Res Function(AzkarItem) _then;

/// Create a copy of AzkarItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? zekr = null,Object? description = null,Object? count = null,Object? reference = null,Object? currentCount = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,zekr: null == zekr ? _self.zekr : zekr // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,currentCount: null == currentCount ? _self.currentCount : currentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AzkarItem].
extension AzkarItemPatterns on AzkarItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AzkarItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AzkarItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AzkarItem value)  $default,){
final _that = this;
switch (_that) {
case _AzkarItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AzkarItem value)?  $default,){
final _that = this;
switch (_that) {
case _AzkarItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  String zekr,  String description,  int count,  String reference,  int currentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AzkarItem() when $default != null:
return $default(_that.category,_that.zekr,_that.description,_that.count,_that.reference,_that.currentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  String zekr,  String description,  int count,  String reference,  int currentCount)  $default,) {final _that = this;
switch (_that) {
case _AzkarItem():
return $default(_that.category,_that.zekr,_that.description,_that.count,_that.reference,_that.currentCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  String zekr,  String description,  int count,  String reference,  int currentCount)?  $default,) {final _that = this;
switch (_that) {
case _AzkarItem() when $default != null:
return $default(_that.category,_that.zekr,_that.description,_that.count,_that.reference,_that.currentCount);case _:
  return null;

}
}

}

/// @nodoc


class _AzkarItem implements AzkarItem {
  const _AzkarItem({required this.category, required this.zekr, required this.description, required this.count, required this.reference, this.currentCount = 0});
  

@override final  String category;
@override final  String zekr;
@override final  String description;
@override final  int count;
@override final  String reference;
@override@JsonKey() final  int currentCount;

/// Create a copy of AzkarItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AzkarItemCopyWith<_AzkarItem> get copyWith => __$AzkarItemCopyWithImpl<_AzkarItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AzkarItem&&(identical(other.category, category) || other.category == category)&&(identical(other.zekr, zekr) || other.zekr == zekr)&&(identical(other.description, description) || other.description == description)&&(identical(other.count, count) || other.count == count)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.currentCount, currentCount) || other.currentCount == currentCount));
}


@override
int get hashCode => Object.hash(runtimeType,category,zekr,description,count,reference,currentCount);

@override
String toString() {
  return 'AzkarItem(category: $category, zekr: $zekr, description: $description, count: $count, reference: $reference, currentCount: $currentCount)';
}


}

/// @nodoc
abstract mixin class _$AzkarItemCopyWith<$Res> implements $AzkarItemCopyWith<$Res> {
  factory _$AzkarItemCopyWith(_AzkarItem value, $Res Function(_AzkarItem) _then) = __$AzkarItemCopyWithImpl;
@override @useResult
$Res call({
 String category, String zekr, String description, int count, String reference, int currentCount
});




}
/// @nodoc
class __$AzkarItemCopyWithImpl<$Res>
    implements _$AzkarItemCopyWith<$Res> {
  __$AzkarItemCopyWithImpl(this._self, this._then);

  final _AzkarItem _self;
  final $Res Function(_AzkarItem) _then;

/// Create a copy of AzkarItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? zekr = null,Object? description = null,Object? count = null,Object? reference = null,Object? currentCount = null,}) {
  return _then(_AzkarItem(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,zekr: null == zekr ? _self.zekr : zekr // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,currentCount: null == currentCount ? _self.currentCount : currentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
