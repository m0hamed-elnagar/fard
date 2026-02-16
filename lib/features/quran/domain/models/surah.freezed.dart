// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'surah.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Surah {

 int get number; String get name; String get englishName; String get englishNameTranslation; int get numberOfAyahs; String get revelationType;
/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahCopyWith<Surah> get copyWith => _$SurahCopyWithImpl<Surah>(this as Surah, _$identity);

  /// Serializes this Surah to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Surah&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,numberOfAyahs,revelationType);

@override
String toString() {
  return 'Surah(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, numberOfAyahs: $numberOfAyahs, revelationType: $revelationType)';
}


}

/// @nodoc
abstract mixin class $SurahCopyWith<$Res>  {
  factory $SurahCopyWith(Surah value, $Res Function(Surah) _then) = _$SurahCopyWithImpl;
@useResult
$Res call({
 int number, String name, String englishName, String englishNameTranslation, int numberOfAyahs, String revelationType
});




}
/// @nodoc
class _$SurahCopyWithImpl<$Res>
    implements $SurahCopyWith<$Res> {
  _$SurahCopyWithImpl(this._self, this._then);

  final Surah _self;
  final $Res Function(Surah) _then;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? numberOfAyahs = null,Object? revelationType = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Surah].
extension SurahPatterns on Surah {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Surah value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Surah() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Surah value)  $default,){
final _that = this;
switch (_that) {
case _Surah():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Surah value)?  $default,){
final _that = this;
switch (_that) {
case _Surah() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String name,  String englishName,  String englishNameTranslation,  int numberOfAyahs,  String revelationType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.numberOfAyahs,_that.revelationType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String name,  String englishName,  String englishNameTranslation,  int numberOfAyahs,  String revelationType)  $default,) {final _that = this;
switch (_that) {
case _Surah():
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.numberOfAyahs,_that.revelationType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String name,  String englishName,  String englishNameTranslation,  int numberOfAyahs,  String revelationType)?  $default,) {final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.numberOfAyahs,_that.revelationType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Surah implements Surah {
  const _Surah({required this.number, required this.name, required this.englishName, required this.englishNameTranslation, required this.numberOfAyahs, required this.revelationType});
  factory _Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);

@override final  int number;
@override final  String name;
@override final  String englishName;
@override final  String englishNameTranslation;
@override final  int numberOfAyahs;
@override final  String revelationType;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahCopyWith<_Surah> get copyWith => __$SurahCopyWithImpl<_Surah>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurahToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Surah&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,numberOfAyahs,revelationType);

@override
String toString() {
  return 'Surah(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, numberOfAyahs: $numberOfAyahs, revelationType: $revelationType)';
}


}

/// @nodoc
abstract mixin class _$SurahCopyWith<$Res> implements $SurahCopyWith<$Res> {
  factory _$SurahCopyWith(_Surah value, $Res Function(_Surah) _then) = __$SurahCopyWithImpl;
@override @useResult
$Res call({
 int number, String name, String englishName, String englishNameTranslation, int numberOfAyahs, String revelationType
});




}
/// @nodoc
class __$SurahCopyWithImpl<$Res>
    implements _$SurahCopyWith<$Res> {
  __$SurahCopyWithImpl(this._self, this._then);

  final _Surah _self;
  final $Res Function(_Surah) _then;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? numberOfAyahs = null,Object? revelationType = null,}) {
  return _then(_Surah(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SurahDetail {

 int get number; String get name; String get englishName; String get englishNameTranslation; String get revelationType; int get numberOfAyahs; List<Ayah> get ayahs;
/// Create a copy of SurahDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahDetailCopyWith<SurahDetail> get copyWith => _$SurahDetailCopyWithImpl<SurahDetail>(this as SurahDetail, _$identity);

  /// Serializes this SurahDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurahDetail&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&const DeepCollectionEquality().equals(other.ayahs, ayahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,revelationType,numberOfAyahs,const DeepCollectionEquality().hash(ayahs));

@override
String toString() {
  return 'SurahDetail(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, revelationType: $revelationType, numberOfAyahs: $numberOfAyahs, ayahs: $ayahs)';
}


}

/// @nodoc
abstract mixin class $SurahDetailCopyWith<$Res>  {
  factory $SurahDetailCopyWith(SurahDetail value, $Res Function(SurahDetail) _then) = _$SurahDetailCopyWithImpl;
@useResult
$Res call({
 int number, String name, String englishName, String englishNameTranslation, String revelationType, int numberOfAyahs, List<Ayah> ayahs
});




}
/// @nodoc
class _$SurahDetailCopyWithImpl<$Res>
    implements $SurahDetailCopyWith<$Res> {
  _$SurahDetailCopyWithImpl(this._self, this._then);

  final SurahDetail _self;
  final $Res Function(SurahDetail) _then;

/// Create a copy of SurahDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? revelationType = null,Object? numberOfAyahs = null,Object? ayahs = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,ayahs: null == ayahs ? _self.ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<Ayah>,
  ));
}

}


/// Adds pattern-matching-related methods to [SurahDetail].
extension SurahDetailPatterns on SurahDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurahDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurahDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurahDetail value)  $default,){
final _that = this;
switch (_that) {
case _SurahDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurahDetail value)?  $default,){
final _that = this;
switch (_that) {
case _SurahDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String name,  String englishName,  String englishNameTranslation,  String revelationType,  int numberOfAyahs,  List<Ayah> ayahs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurahDetail() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.revelationType,_that.numberOfAyahs,_that.ayahs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String name,  String englishName,  String englishNameTranslation,  String revelationType,  int numberOfAyahs,  List<Ayah> ayahs)  $default,) {final _that = this;
switch (_that) {
case _SurahDetail():
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.revelationType,_that.numberOfAyahs,_that.ayahs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String name,  String englishName,  String englishNameTranslation,  String revelationType,  int numberOfAyahs,  List<Ayah> ayahs)?  $default,) {final _that = this;
switch (_that) {
case _SurahDetail() when $default != null:
return $default(_that.number,_that.name,_that.englishName,_that.englishNameTranslation,_that.revelationType,_that.numberOfAyahs,_that.ayahs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurahDetail implements SurahDetail {
  const _SurahDetail({required this.number, required this.name, required this.englishName, required this.englishNameTranslation, required this.revelationType, required this.numberOfAyahs, required final  List<Ayah> ayahs}): _ayahs = ayahs;
  factory _SurahDetail.fromJson(Map<String, dynamic> json) => _$SurahDetailFromJson(json);

@override final  int number;
@override final  String name;
@override final  String englishName;
@override final  String englishNameTranslation;
@override final  String revelationType;
@override final  int numberOfAyahs;
 final  List<Ayah> _ayahs;
@override List<Ayah> get ayahs {
  if (_ayahs is EqualUnmodifiableListView) return _ayahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ayahs);
}


/// Create a copy of SurahDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahDetailCopyWith<_SurahDetail> get copyWith => __$SurahDetailCopyWithImpl<_SurahDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurahDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurahDetail&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.englishNameTranslation, englishNameTranslation) || other.englishNameTranslation == englishNameTranslation)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.numberOfAyahs, numberOfAyahs) || other.numberOfAyahs == numberOfAyahs)&&const DeepCollectionEquality().equals(other._ayahs, _ayahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,name,englishName,englishNameTranslation,revelationType,numberOfAyahs,const DeepCollectionEquality().hash(_ayahs));

@override
String toString() {
  return 'SurahDetail(number: $number, name: $name, englishName: $englishName, englishNameTranslation: $englishNameTranslation, revelationType: $revelationType, numberOfAyahs: $numberOfAyahs, ayahs: $ayahs)';
}


}

/// @nodoc
abstract mixin class _$SurahDetailCopyWith<$Res> implements $SurahDetailCopyWith<$Res> {
  factory _$SurahDetailCopyWith(_SurahDetail value, $Res Function(_SurahDetail) _then) = __$SurahDetailCopyWithImpl;
@override @useResult
$Res call({
 int number, String name, String englishName, String englishNameTranslation, String revelationType, int numberOfAyahs, List<Ayah> ayahs
});




}
/// @nodoc
class __$SurahDetailCopyWithImpl<$Res>
    implements _$SurahDetailCopyWith<$Res> {
  __$SurahDetailCopyWithImpl(this._self, this._then);

  final _SurahDetail _self;
  final $Res Function(_SurahDetail) _then;

/// Create a copy of SurahDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? name = null,Object? englishName = null,Object? englishNameTranslation = null,Object? revelationType = null,Object? numberOfAyahs = null,Object? ayahs = null,}) {
  return _then(_SurahDetail(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,englishNameTranslation: null == englishNameTranslation ? _self.englishNameTranslation : englishNameTranslation // ignore: cast_nullable_to_non_nullable
as String,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,numberOfAyahs: null == numberOfAyahs ? _self.numberOfAyahs : numberOfAyahs // ignore: cast_nullable_to_non_nullable
as int,ayahs: null == ayahs ? _self._ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<Ayah>,
  ));
}


}

// dart format on
