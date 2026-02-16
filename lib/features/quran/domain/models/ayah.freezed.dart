// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ayah {

 int get number; String get text; int get numberInSurah; int get juz; int get manzil; int get page; int get ruku; int get hizbQuarter; bool get sajda;
/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahCopyWith<Ayah> get copyWith => _$AyahCopyWithImpl<Ayah>(this as Ayah, _$identity);

  /// Serializes this Ayah to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ayah&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text)&&(identical(other.numberInSurah, numberInSurah) || other.numberInSurah == numberInSurah)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.manzil, manzil) || other.manzil == manzil)&&(identical(other.page, page) || other.page == page)&&(identical(other.ruku, ruku) || other.ruku == ruku)&&(identical(other.hizbQuarter, hizbQuarter) || other.hizbQuarter == hizbQuarter)&&(identical(other.sajda, sajda) || other.sajda == sajda));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,text,numberInSurah,juz,manzil,page,ruku,hizbQuarter,sajda);

@override
String toString() {
  return 'Ayah(number: $number, text: $text, numberInSurah: $numberInSurah, juz: $juz, manzil: $manzil, page: $page, ruku: $ruku, hizbQuarter: $hizbQuarter, sajda: $sajda)';
}


}

/// @nodoc
abstract mixin class $AyahCopyWith<$Res>  {
  factory $AyahCopyWith(Ayah value, $Res Function(Ayah) _then) = _$AyahCopyWithImpl;
@useResult
$Res call({
 int number, String text, int numberInSurah, int juz, int manzil, int page, int ruku, int hizbQuarter, bool sajda
});




}
/// @nodoc
class _$AyahCopyWithImpl<$Res>
    implements $AyahCopyWith<$Res> {
  _$AyahCopyWithImpl(this._self, this._then);

  final Ayah _self;
  final $Res Function(Ayah) _then;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? text = null,Object? numberInSurah = null,Object? juz = null,Object? manzil = null,Object? page = null,Object? ruku = null,Object? hizbQuarter = null,Object? sajda = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,numberInSurah: null == numberInSurah ? _self.numberInSurah : numberInSurah // ignore: cast_nullable_to_non_nullable
as int,juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,manzil: null == manzil ? _self.manzil : manzil // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,ruku: null == ruku ? _self.ruku : ruku // ignore: cast_nullable_to_non_nullable
as int,hizbQuarter: null == hizbQuarter ? _self.hizbQuarter : hizbQuarter // ignore: cast_nullable_to_non_nullable
as int,sajda: null == sajda ? _self.sajda : sajda // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Ayah].
extension AyahPatterns on Ayah {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ayah value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ayah() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ayah value)  $default,){
final _that = this;
switch (_that) {
case _Ayah():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ayah value)?  $default,){
final _that = this;
switch (_that) {
case _Ayah() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String text,  int numberInSurah,  int juz,  int manzil,  int page,  int ruku,  int hizbQuarter,  bool sajda)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ayah() when $default != null:
return $default(_that.number,_that.text,_that.numberInSurah,_that.juz,_that.manzil,_that.page,_that.ruku,_that.hizbQuarter,_that.sajda);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String text,  int numberInSurah,  int juz,  int manzil,  int page,  int ruku,  int hizbQuarter,  bool sajda)  $default,) {final _that = this;
switch (_that) {
case _Ayah():
return $default(_that.number,_that.text,_that.numberInSurah,_that.juz,_that.manzil,_that.page,_that.ruku,_that.hizbQuarter,_that.sajda);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String text,  int numberInSurah,  int juz,  int manzil,  int page,  int ruku,  int hizbQuarter,  bool sajda)?  $default,) {final _that = this;
switch (_that) {
case _Ayah() when $default != null:
return $default(_that.number,_that.text,_that.numberInSurah,_that.juz,_that.manzil,_that.page,_that.ruku,_that.hizbQuarter,_that.sajda);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ayah implements Ayah {
  const _Ayah({required this.number, required this.text, required this.numberInSurah, required this.juz, required this.manzil, required this.page, required this.ruku, required this.hizbQuarter, this.sajda = false});
  factory _Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);

@override final  int number;
@override final  String text;
@override final  int numberInSurah;
@override final  int juz;
@override final  int manzil;
@override final  int page;
@override final  int ruku;
@override final  int hizbQuarter;
@override@JsonKey() final  bool sajda;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahCopyWith<_Ayah> get copyWith => __$AyahCopyWithImpl<_Ayah>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AyahToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ayah&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text)&&(identical(other.numberInSurah, numberInSurah) || other.numberInSurah == numberInSurah)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.manzil, manzil) || other.manzil == manzil)&&(identical(other.page, page) || other.page == page)&&(identical(other.ruku, ruku) || other.ruku == ruku)&&(identical(other.hizbQuarter, hizbQuarter) || other.hizbQuarter == hizbQuarter)&&(identical(other.sajda, sajda) || other.sajda == sajda));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,text,numberInSurah,juz,manzil,page,ruku,hizbQuarter,sajda);

@override
String toString() {
  return 'Ayah(number: $number, text: $text, numberInSurah: $numberInSurah, juz: $juz, manzil: $manzil, page: $page, ruku: $ruku, hizbQuarter: $hizbQuarter, sajda: $sajda)';
}


}

/// @nodoc
abstract mixin class _$AyahCopyWith<$Res> implements $AyahCopyWith<$Res> {
  factory _$AyahCopyWith(_Ayah value, $Res Function(_Ayah) _then) = __$AyahCopyWithImpl;
@override @useResult
$Res call({
 int number, String text, int numberInSurah, int juz, int manzil, int page, int ruku, int hizbQuarter, bool sajda
});




}
/// @nodoc
class __$AyahCopyWithImpl<$Res>
    implements _$AyahCopyWith<$Res> {
  __$AyahCopyWithImpl(this._self, this._then);

  final _Ayah _self;
  final $Res Function(_Ayah) _then;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? text = null,Object? numberInSurah = null,Object? juz = null,Object? manzil = null,Object? page = null,Object? ruku = null,Object? hizbQuarter = null,Object? sajda = null,}) {
  return _then(_Ayah(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,numberInSurah: null == numberInSurah ? _self.numberInSurah : numberInSurah // ignore: cast_nullable_to_non_nullable
as int,juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,manzil: null == manzil ? _self.manzil : manzil // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,ruku: null == ruku ? _self.ruku : ruku // ignore: cast_nullable_to_non_nullable
as int,hizbQuarter: null == hizbQuarter ? _self.hizbQuarter : hizbQuarter // ignore: cast_nullable_to_non_nullable
as int,sajda: null == sajda ? _self.sajda : sajda // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
