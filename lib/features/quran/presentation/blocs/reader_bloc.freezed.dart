// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReaderEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReaderEvent()';
}


}

/// @nodoc
class $ReaderEventCopyWith<$Res>  {
$ReaderEventCopyWith(ReaderEvent _, $Res Function(ReaderEvent) __);
}


/// Adds pattern-matching-related methods to [ReaderEvent].
extension ReaderEventPatterns on ReaderEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadSurah value)?  loadSurah,TResult Function( _SelectAyah value)?  selectAyah,TResult Function( _SaveLastRead value)?  saveLastRead,TResult Function( _UpdateScale value)?  updateScale,TResult Function( _UpdateFontFamily value)?  updateFontFamily,TResult Function( _UpdateSeparator value)?  updateSeparator,TResult Function( _ToggleBookmark value)?  toggleBookmark,TResult Function( _CheckBookmark value)?  checkBookmark,TResult Function( _BookmarksUpdated value)?  bookmarksUpdated,TResult Function( _UpdateTafsir value)?  updateTafsir,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadSurah() when loadSurah != null:
return loadSurah(_that);case _SelectAyah() when selectAyah != null:
return selectAyah(_that);case _SaveLastRead() when saveLastRead != null:
return saveLastRead(_that);case _UpdateScale() when updateScale != null:
return updateScale(_that);case _UpdateFontFamily() when updateFontFamily != null:
return updateFontFamily(_that);case _UpdateSeparator() when updateSeparator != null:
return updateSeparator(_that);case _ToggleBookmark() when toggleBookmark != null:
return toggleBookmark(_that);case _CheckBookmark() when checkBookmark != null:
return checkBookmark(_that);case _BookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that);case _UpdateTafsir() when updateTafsir != null:
return updateTafsir(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadSurah value)  loadSurah,required TResult Function( _SelectAyah value)  selectAyah,required TResult Function( _SaveLastRead value)  saveLastRead,required TResult Function( _UpdateScale value)  updateScale,required TResult Function( _UpdateFontFamily value)  updateFontFamily,required TResult Function( _UpdateSeparator value)  updateSeparator,required TResult Function( _ToggleBookmark value)  toggleBookmark,required TResult Function( _CheckBookmark value)  checkBookmark,required TResult Function( _BookmarksUpdated value)  bookmarksUpdated,required TResult Function( _UpdateTafsir value)  updateTafsir,}){
final _that = this;
switch (_that) {
case _LoadSurah():
return loadSurah(_that);case _SelectAyah():
return selectAyah(_that);case _SaveLastRead():
return saveLastRead(_that);case _UpdateScale():
return updateScale(_that);case _UpdateFontFamily():
return updateFontFamily(_that);case _UpdateSeparator():
return updateSeparator(_that);case _ToggleBookmark():
return toggleBookmark(_that);case _CheckBookmark():
return checkBookmark(_that);case _BookmarksUpdated():
return bookmarksUpdated(_that);case _UpdateTafsir():
return updateTafsir(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadSurah value)?  loadSurah,TResult? Function( _SelectAyah value)?  selectAyah,TResult? Function( _SaveLastRead value)?  saveLastRead,TResult? Function( _UpdateScale value)?  updateScale,TResult? Function( _UpdateFontFamily value)?  updateFontFamily,TResult? Function( _UpdateSeparator value)?  updateSeparator,TResult? Function( _ToggleBookmark value)?  toggleBookmark,TResult? Function( _CheckBookmark value)?  checkBookmark,TResult? Function( _BookmarksUpdated value)?  bookmarksUpdated,TResult? Function( _UpdateTafsir value)?  updateTafsir,}){
final _that = this;
switch (_that) {
case _LoadSurah() when loadSurah != null:
return loadSurah(_that);case _SelectAyah() when selectAyah != null:
return selectAyah(_that);case _SaveLastRead() when saveLastRead != null:
return saveLastRead(_that);case _UpdateScale() when updateScale != null:
return updateScale(_that);case _UpdateFontFamily() when updateFontFamily != null:
return updateFontFamily(_that);case _UpdateSeparator() when updateSeparator != null:
return updateSeparator(_that);case _ToggleBookmark() when toggleBookmark != null:
return toggleBookmark(_that);case _CheckBookmark() when checkBookmark != null:
return checkBookmark(_that);case _BookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that);case _UpdateTafsir() when updateTafsir != null:
return updateTafsir(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SurahNumber surahNumber,  int? initialAyahNumber)?  loadSurah,TResult Function( Ayah ayah)?  selectAyah,TResult Function( Ayah ayah)?  saveLastRead,TResult Function( double scale)?  updateScale,TResult Function( String fontFamily)?  updateFontFamily,TResult Function( ReaderSeparator separator)?  updateSeparator,TResult Function( Ayah ayah)?  toggleBookmark,TResult Function( Ayah ayah)?  checkBookmark,TResult Function( List<Bookmark> bookmarks)?  bookmarksUpdated,TResult Function( int tafsirId)?  updateTafsir,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadSurah() when loadSurah != null:
return loadSurah(_that.surahNumber,_that.initialAyahNumber);case _SelectAyah() when selectAyah != null:
return selectAyah(_that.ayah);case _SaveLastRead() when saveLastRead != null:
return saveLastRead(_that.ayah);case _UpdateScale() when updateScale != null:
return updateScale(_that.scale);case _UpdateFontFamily() when updateFontFamily != null:
return updateFontFamily(_that.fontFamily);case _UpdateSeparator() when updateSeparator != null:
return updateSeparator(_that.separator);case _ToggleBookmark() when toggleBookmark != null:
return toggleBookmark(_that.ayah);case _CheckBookmark() when checkBookmark != null:
return checkBookmark(_that.ayah);case _BookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that.bookmarks);case _UpdateTafsir() when updateTafsir != null:
return updateTafsir(_that.tafsirId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SurahNumber surahNumber,  int? initialAyahNumber)  loadSurah,required TResult Function( Ayah ayah)  selectAyah,required TResult Function( Ayah ayah)  saveLastRead,required TResult Function( double scale)  updateScale,required TResult Function( String fontFamily)  updateFontFamily,required TResult Function( ReaderSeparator separator)  updateSeparator,required TResult Function( Ayah ayah)  toggleBookmark,required TResult Function( Ayah ayah)  checkBookmark,required TResult Function( List<Bookmark> bookmarks)  bookmarksUpdated,required TResult Function( int tafsirId)  updateTafsir,}) {final _that = this;
switch (_that) {
case _LoadSurah():
return loadSurah(_that.surahNumber,_that.initialAyahNumber);case _SelectAyah():
return selectAyah(_that.ayah);case _SaveLastRead():
return saveLastRead(_that.ayah);case _UpdateScale():
return updateScale(_that.scale);case _UpdateFontFamily():
return updateFontFamily(_that.fontFamily);case _UpdateSeparator():
return updateSeparator(_that.separator);case _ToggleBookmark():
return toggleBookmark(_that.ayah);case _CheckBookmark():
return checkBookmark(_that.ayah);case _BookmarksUpdated():
return bookmarksUpdated(_that.bookmarks);case _UpdateTafsir():
return updateTafsir(_that.tafsirId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SurahNumber surahNumber,  int? initialAyahNumber)?  loadSurah,TResult? Function( Ayah ayah)?  selectAyah,TResult? Function( Ayah ayah)?  saveLastRead,TResult? Function( double scale)?  updateScale,TResult? Function( String fontFamily)?  updateFontFamily,TResult? Function( ReaderSeparator separator)?  updateSeparator,TResult? Function( Ayah ayah)?  toggleBookmark,TResult? Function( Ayah ayah)?  checkBookmark,TResult? Function( List<Bookmark> bookmarks)?  bookmarksUpdated,TResult? Function( int tafsirId)?  updateTafsir,}) {final _that = this;
switch (_that) {
case _LoadSurah() when loadSurah != null:
return loadSurah(_that.surahNumber,_that.initialAyahNumber);case _SelectAyah() when selectAyah != null:
return selectAyah(_that.ayah);case _SaveLastRead() when saveLastRead != null:
return saveLastRead(_that.ayah);case _UpdateScale() when updateScale != null:
return updateScale(_that.scale);case _UpdateFontFamily() when updateFontFamily != null:
return updateFontFamily(_that.fontFamily);case _UpdateSeparator() when updateSeparator != null:
return updateSeparator(_that.separator);case _ToggleBookmark() when toggleBookmark != null:
return toggleBookmark(_that.ayah);case _CheckBookmark() when checkBookmark != null:
return checkBookmark(_that.ayah);case _BookmarksUpdated() when bookmarksUpdated != null:
return bookmarksUpdated(_that.bookmarks);case _UpdateTafsir() when updateTafsir != null:
return updateTafsir(_that.tafsirId);case _:
  return null;

}
}

}

/// @nodoc


class _LoadSurah implements ReaderEvent {
  const _LoadSurah({required this.surahNumber, this.initialAyahNumber});
  

 final  SurahNumber surahNumber;
 final  int? initialAyahNumber;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadSurahCopyWith<_LoadSurah> get copyWith => __$LoadSurahCopyWithImpl<_LoadSurah>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadSurah&&(identical(other.surahNumber, surahNumber) || other.surahNumber == surahNumber)&&(identical(other.initialAyahNumber, initialAyahNumber) || other.initialAyahNumber == initialAyahNumber));
}


@override
int get hashCode => Object.hash(runtimeType,surahNumber,initialAyahNumber);

@override
String toString() {
  return 'ReaderEvent.loadSurah(surahNumber: $surahNumber, initialAyahNumber: $initialAyahNumber)';
}


}

/// @nodoc
abstract mixin class _$LoadSurahCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$LoadSurahCopyWith(_LoadSurah value, $Res Function(_LoadSurah) _then) = __$LoadSurahCopyWithImpl;
@useResult
$Res call({
 SurahNumber surahNumber, int? initialAyahNumber
});




}
/// @nodoc
class __$LoadSurahCopyWithImpl<$Res>
    implements _$LoadSurahCopyWith<$Res> {
  __$LoadSurahCopyWithImpl(this._self, this._then);

  final _LoadSurah _self;
  final $Res Function(_LoadSurah) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? surahNumber = null,Object? initialAyahNumber = freezed,}) {
  return _then(_LoadSurah(
surahNumber: null == surahNumber ? _self.surahNumber : surahNumber // ignore: cast_nullable_to_non_nullable
as SurahNumber,initialAyahNumber: freezed == initialAyahNumber ? _self.initialAyahNumber : initialAyahNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _SelectAyah implements ReaderEvent {
  const _SelectAyah(this.ayah);
  

 final  Ayah ayah;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectAyahCopyWith<_SelectAyah> get copyWith => __$SelectAyahCopyWithImpl<_SelectAyah>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectAyah&&(identical(other.ayah, ayah) || other.ayah == ayah));
}


@override
int get hashCode => Object.hash(runtimeType,ayah);

@override
String toString() {
  return 'ReaderEvent.selectAyah(ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$SelectAyahCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$SelectAyahCopyWith(_SelectAyah value, $Res Function(_SelectAyah) _then) = __$SelectAyahCopyWithImpl;
@useResult
$Res call({
 Ayah ayah
});




}
/// @nodoc
class __$SelectAyahCopyWithImpl<$Res>
    implements _$SelectAyahCopyWith<$Res> {
  __$SelectAyahCopyWithImpl(this._self, this._then);

  final _SelectAyah _self;
  final $Res Function(_SelectAyah) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ayah = null,}) {
  return _then(_SelectAyah(
null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as Ayah,
  ));
}


}

/// @nodoc


class _SaveLastRead implements ReaderEvent {
  const _SaveLastRead(this.ayah);
  

 final  Ayah ayah;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveLastReadCopyWith<_SaveLastRead> get copyWith => __$SaveLastReadCopyWithImpl<_SaveLastRead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveLastRead&&(identical(other.ayah, ayah) || other.ayah == ayah));
}


@override
int get hashCode => Object.hash(runtimeType,ayah);

@override
String toString() {
  return 'ReaderEvent.saveLastRead(ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$SaveLastReadCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$SaveLastReadCopyWith(_SaveLastRead value, $Res Function(_SaveLastRead) _then) = __$SaveLastReadCopyWithImpl;
@useResult
$Res call({
 Ayah ayah
});




}
/// @nodoc
class __$SaveLastReadCopyWithImpl<$Res>
    implements _$SaveLastReadCopyWith<$Res> {
  __$SaveLastReadCopyWithImpl(this._self, this._then);

  final _SaveLastRead _self;
  final $Res Function(_SaveLastRead) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ayah = null,}) {
  return _then(_SaveLastRead(
null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as Ayah,
  ));
}


}

/// @nodoc


class _UpdateScale implements ReaderEvent {
  const _UpdateScale(this.scale);
  

 final  double scale;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateScaleCopyWith<_UpdateScale> get copyWith => __$UpdateScaleCopyWithImpl<_UpdateScale>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateScale&&(identical(other.scale, scale) || other.scale == scale));
}


@override
int get hashCode => Object.hash(runtimeType,scale);

@override
String toString() {
  return 'ReaderEvent.updateScale(scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$UpdateScaleCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$UpdateScaleCopyWith(_UpdateScale value, $Res Function(_UpdateScale) _then) = __$UpdateScaleCopyWithImpl;
@useResult
$Res call({
 double scale
});




}
/// @nodoc
class __$UpdateScaleCopyWithImpl<$Res>
    implements _$UpdateScaleCopyWith<$Res> {
  __$UpdateScaleCopyWithImpl(this._self, this._then);

  final _UpdateScale _self;
  final $Res Function(_UpdateScale) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scale = null,}) {
  return _then(_UpdateScale(
null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class _UpdateFontFamily implements ReaderEvent {
  const _UpdateFontFamily(this.fontFamily);
  

 final  String fontFamily;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateFontFamilyCopyWith<_UpdateFontFamily> get copyWith => __$UpdateFontFamilyCopyWithImpl<_UpdateFontFamily>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateFontFamily&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily));
}


@override
int get hashCode => Object.hash(runtimeType,fontFamily);

@override
String toString() {
  return 'ReaderEvent.updateFontFamily(fontFamily: $fontFamily)';
}


}

/// @nodoc
abstract mixin class _$UpdateFontFamilyCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$UpdateFontFamilyCopyWith(_UpdateFontFamily value, $Res Function(_UpdateFontFamily) _then) = __$UpdateFontFamilyCopyWithImpl;
@useResult
$Res call({
 String fontFamily
});




}
/// @nodoc
class __$UpdateFontFamilyCopyWithImpl<$Res>
    implements _$UpdateFontFamilyCopyWith<$Res> {
  __$UpdateFontFamilyCopyWithImpl(this._self, this._then);

  final _UpdateFontFamily _self;
  final $Res Function(_UpdateFontFamily) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fontFamily = null,}) {
  return _then(_UpdateFontFamily(
null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UpdateSeparator implements ReaderEvent {
  const _UpdateSeparator(this.separator);
  

 final  ReaderSeparator separator;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSeparatorCopyWith<_UpdateSeparator> get copyWith => __$UpdateSeparatorCopyWithImpl<_UpdateSeparator>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSeparator&&(identical(other.separator, separator) || other.separator == separator));
}


@override
int get hashCode => Object.hash(runtimeType,separator);

@override
String toString() {
  return 'ReaderEvent.updateSeparator(separator: $separator)';
}


}

/// @nodoc
abstract mixin class _$UpdateSeparatorCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$UpdateSeparatorCopyWith(_UpdateSeparator value, $Res Function(_UpdateSeparator) _then) = __$UpdateSeparatorCopyWithImpl;
@useResult
$Res call({
 ReaderSeparator separator
});




}
/// @nodoc
class __$UpdateSeparatorCopyWithImpl<$Res>
    implements _$UpdateSeparatorCopyWith<$Res> {
  __$UpdateSeparatorCopyWithImpl(this._self, this._then);

  final _UpdateSeparator _self;
  final $Res Function(_UpdateSeparator) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? separator = null,}) {
  return _then(_UpdateSeparator(
null == separator ? _self.separator : separator // ignore: cast_nullable_to_non_nullable
as ReaderSeparator,
  ));
}


}

/// @nodoc


class _ToggleBookmark implements ReaderEvent {
  const _ToggleBookmark(this.ayah);
  

 final  Ayah ayah;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleBookmarkCopyWith<_ToggleBookmark> get copyWith => __$ToggleBookmarkCopyWithImpl<_ToggleBookmark>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleBookmark&&(identical(other.ayah, ayah) || other.ayah == ayah));
}


@override
int get hashCode => Object.hash(runtimeType,ayah);

@override
String toString() {
  return 'ReaderEvent.toggleBookmark(ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$ToggleBookmarkCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$ToggleBookmarkCopyWith(_ToggleBookmark value, $Res Function(_ToggleBookmark) _then) = __$ToggleBookmarkCopyWithImpl;
@useResult
$Res call({
 Ayah ayah
});




}
/// @nodoc
class __$ToggleBookmarkCopyWithImpl<$Res>
    implements _$ToggleBookmarkCopyWith<$Res> {
  __$ToggleBookmarkCopyWithImpl(this._self, this._then);

  final _ToggleBookmark _self;
  final $Res Function(_ToggleBookmark) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ayah = null,}) {
  return _then(_ToggleBookmark(
null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as Ayah,
  ));
}


}

/// @nodoc


class _CheckBookmark implements ReaderEvent {
  const _CheckBookmark(this.ayah);
  

 final  Ayah ayah;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckBookmarkCopyWith<_CheckBookmark> get copyWith => __$CheckBookmarkCopyWithImpl<_CheckBookmark>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckBookmark&&(identical(other.ayah, ayah) || other.ayah == ayah));
}


@override
int get hashCode => Object.hash(runtimeType,ayah);

@override
String toString() {
  return 'ReaderEvent.checkBookmark(ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$CheckBookmarkCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$CheckBookmarkCopyWith(_CheckBookmark value, $Res Function(_CheckBookmark) _then) = __$CheckBookmarkCopyWithImpl;
@useResult
$Res call({
 Ayah ayah
});




}
/// @nodoc
class __$CheckBookmarkCopyWithImpl<$Res>
    implements _$CheckBookmarkCopyWith<$Res> {
  __$CheckBookmarkCopyWithImpl(this._self, this._then);

  final _CheckBookmark _self;
  final $Res Function(_CheckBookmark) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ayah = null,}) {
  return _then(_CheckBookmark(
null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as Ayah,
  ));
}


}

/// @nodoc


class _BookmarksUpdated implements ReaderEvent {
  const _BookmarksUpdated(final  List<Bookmark> bookmarks): _bookmarks = bookmarks;
  

 final  List<Bookmark> _bookmarks;
 List<Bookmark> get bookmarks {
  if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookmarks);
}


/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarksUpdatedCopyWith<_BookmarksUpdated> get copyWith => __$BookmarksUpdatedCopyWithImpl<_BookmarksUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarksUpdated&&const DeepCollectionEquality().equals(other._bookmarks, _bookmarks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookmarks));

@override
String toString() {
  return 'ReaderEvent.bookmarksUpdated(bookmarks: $bookmarks)';
}


}

/// @nodoc
abstract mixin class _$BookmarksUpdatedCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$BookmarksUpdatedCopyWith(_BookmarksUpdated value, $Res Function(_BookmarksUpdated) _then) = __$BookmarksUpdatedCopyWithImpl;
@useResult
$Res call({
 List<Bookmark> bookmarks
});




}
/// @nodoc
class __$BookmarksUpdatedCopyWithImpl<$Res>
    implements _$BookmarksUpdatedCopyWith<$Res> {
  __$BookmarksUpdatedCopyWithImpl(this._self, this._then);

  final _BookmarksUpdated _self;
  final $Res Function(_BookmarksUpdated) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookmarks = null,}) {
  return _then(_BookmarksUpdated(
null == bookmarks ? _self._bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,
  ));
}


}

/// @nodoc


class _UpdateTafsir implements ReaderEvent {
  const _UpdateTafsir(this.tafsirId);
  

 final  int tafsirId;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTafsirCopyWith<_UpdateTafsir> get copyWith => __$UpdateTafsirCopyWithImpl<_UpdateTafsir>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTafsir&&(identical(other.tafsirId, tafsirId) || other.tafsirId == tafsirId));
}


@override
int get hashCode => Object.hash(runtimeType,tafsirId);

@override
String toString() {
  return 'ReaderEvent.updateTafsir(tafsirId: $tafsirId)';
}


}

/// @nodoc
abstract mixin class _$UpdateTafsirCopyWith<$Res> implements $ReaderEventCopyWith<$Res> {
  factory _$UpdateTafsirCopyWith(_UpdateTafsir value, $Res Function(_UpdateTafsir) _then) = __$UpdateTafsirCopyWithImpl;
@useResult
$Res call({
 int tafsirId
});




}
/// @nodoc
class __$UpdateTafsirCopyWithImpl<$Res>
    implements _$UpdateTafsirCopyWith<$Res> {
  __$UpdateTafsirCopyWithImpl(this._self, this._then);

  final _UpdateTafsir _self;
  final $Res Function(_UpdateTafsir) _then;

/// Create a copy of ReaderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tafsirId = null,}) {
  return _then(_UpdateTafsir(
null == tafsirId ? _self.tafsirId : tafsirId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ReaderState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReaderState()';
}


}

/// @nodoc
class $ReaderStateCopyWith<$Res>  {
$ReaderStateCopyWith(ReaderState _, $Res Function(ReaderState) __);
}


/// Adds pattern-matching-related methods to [ReaderState].
extension ReaderStatePatterns on ReaderState {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Surah surah,  Ayah? highlightedAyah,  Ayah? lastReadAyah,  double textScale,  String fontFamily,  ReaderSeparator separator,  int selectedTafsirId,  List<Bookmark> bookmarks)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.surah,_that.highlightedAyah,_that.lastReadAyah,_that.textScale,_that.fontFamily,_that.separator,_that.selectedTafsirId,_that.bookmarks);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Surah surah,  Ayah? highlightedAyah,  Ayah? lastReadAyah,  double textScale,  String fontFamily,  ReaderSeparator separator,  int selectedTafsirId,  List<Bookmark> bookmarks)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.surah,_that.highlightedAyah,_that.lastReadAyah,_that.textScale,_that.fontFamily,_that.separator,_that.selectedTafsirId,_that.bookmarks);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Surah surah,  Ayah? highlightedAyah,  Ayah? lastReadAyah,  double textScale,  String fontFamily,  ReaderSeparator separator,  int selectedTafsirId,  List<Bookmark> bookmarks)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.surah,_that.highlightedAyah,_that.lastReadAyah,_that.textScale,_that.fontFamily,_that.separator,_that.selectedTafsirId,_that.bookmarks);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ReaderState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReaderState.initial()';
}


}




/// @nodoc


class _Loading implements ReaderState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReaderState.loading()';
}


}




/// @nodoc


class _Loaded implements ReaderState {
  const _Loaded({required this.surah, this.highlightedAyah, this.lastReadAyah, this.textScale = 1.0, this.fontFamily = 'Amiri', this.separator = ReaderSeparator.none, this.selectedTafsirId = 16, final  List<Bookmark> bookmarks = const []}): _bookmarks = bookmarks;
  

 final  Surah surah;
 final  Ayah? highlightedAyah;
 final  Ayah? lastReadAyah;
@JsonKey() final  double textScale;
@JsonKey() final  String fontFamily;
@JsonKey() final  ReaderSeparator separator;
@JsonKey() final  int selectedTafsirId;
 final  List<Bookmark> _bookmarks;
@JsonKey() List<Bookmark> get bookmarks {
  if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookmarks);
}


/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.highlightedAyah, highlightedAyah) || other.highlightedAyah == highlightedAyah)&&(identical(other.lastReadAyah, lastReadAyah) || other.lastReadAyah == lastReadAyah)&&(identical(other.textScale, textScale) || other.textScale == textScale)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.separator, separator) || other.separator == separator)&&(identical(other.selectedTafsirId, selectedTafsirId) || other.selectedTafsirId == selectedTafsirId)&&const DeepCollectionEquality().equals(other._bookmarks, _bookmarks));
}


@override
int get hashCode => Object.hash(runtimeType,surah,highlightedAyah,lastReadAyah,textScale,fontFamily,separator,selectedTafsirId,const DeepCollectionEquality().hash(_bookmarks));

@override
String toString() {
  return 'ReaderState.loaded(surah: $surah, highlightedAyah: $highlightedAyah, lastReadAyah: $lastReadAyah, textScale: $textScale, fontFamily: $fontFamily, separator: $separator, selectedTafsirId: $selectedTafsirId, bookmarks: $bookmarks)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $ReaderStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 Surah surah, Ayah? highlightedAyah, Ayah? lastReadAyah, double textScale, String fontFamily, ReaderSeparator separator, int selectedTafsirId, List<Bookmark> bookmarks
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? surah = null,Object? highlightedAyah = freezed,Object? lastReadAyah = freezed,Object? textScale = null,Object? fontFamily = null,Object? separator = null,Object? selectedTafsirId = null,Object? bookmarks = null,}) {
  return _then(_Loaded(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as Surah,highlightedAyah: freezed == highlightedAyah ? _self.highlightedAyah : highlightedAyah // ignore: cast_nullable_to_non_nullable
as Ayah?,lastReadAyah: freezed == lastReadAyah ? _self.lastReadAyah : lastReadAyah // ignore: cast_nullable_to_non_nullable
as Ayah?,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as double,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,separator: null == separator ? _self.separator : separator // ignore: cast_nullable_to_non_nullable
as ReaderSeparator,selectedTafsirId: null == selectedTafsirId ? _self.selectedTafsirId : selectedTafsirId // ignore: cast_nullable_to_non_nullable
as int,bookmarks: null == bookmarks ? _self._bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,
  ));
}


}

/// @nodoc


class _Error implements ReaderState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of ReaderState
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
  return 'ReaderState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ReaderStateCopyWith<$Res> {
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

/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
