// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuranEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QuranEvent()';
}


}

/// @nodoc
class $QuranEventCopyWith<$Res>  {
$QuranEventCopyWith(QuranEvent _, $Res Function(QuranEvent) __);
}


/// Adds pattern-matching-related methods to [QuranEvent].
extension QuranEventPatterns on QuranEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadSurahs value)?  loadSurahs,TResult Function( _LoadSurahDetails value)?  loadSurahDetails,TResult Function( _Search value)?  search,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadSurahs() when loadSurahs != null:
return loadSurahs(_that);case _LoadSurahDetails() when loadSurahDetails != null:
return loadSurahDetails(_that);case _Search() when search != null:
return search(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadSurahs value)  loadSurahs,required TResult Function( _LoadSurahDetails value)  loadSurahDetails,required TResult Function( _Search value)  search,}){
final _that = this;
switch (_that) {
case _LoadSurahs():
return loadSurahs(_that);case _LoadSurahDetails():
return loadSurahDetails(_that);case _Search():
return search(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadSurahs value)?  loadSurahs,TResult? Function( _LoadSurahDetails value)?  loadSurahDetails,TResult? Function( _Search value)?  search,}){
final _that = this;
switch (_that) {
case _LoadSurahs() when loadSurahs != null:
return loadSurahs(_that);case _LoadSurahDetails() when loadSurahDetails != null:
return loadSurahDetails(_that);case _Search() when search != null:
return search(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadSurahs,TResult Function( int surahNumber)?  loadSurahDetails,TResult Function( String query)?  search,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadSurahs() when loadSurahs != null:
return loadSurahs();case _LoadSurahDetails() when loadSurahDetails != null:
return loadSurahDetails(_that.surahNumber);case _Search() when search != null:
return search(_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadSurahs,required TResult Function( int surahNumber)  loadSurahDetails,required TResult Function( String query)  search,}) {final _that = this;
switch (_that) {
case _LoadSurahs():
return loadSurahs();case _LoadSurahDetails():
return loadSurahDetails(_that.surahNumber);case _Search():
return search(_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadSurahs,TResult? Function( int surahNumber)?  loadSurahDetails,TResult? Function( String query)?  search,}) {final _that = this;
switch (_that) {
case _LoadSurahs() when loadSurahs != null:
return loadSurahs();case _LoadSurahDetails() when loadSurahDetails != null:
return loadSurahDetails(_that.surahNumber);case _Search() when search != null:
return search(_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _LoadSurahs implements QuranEvent {
  const _LoadSurahs();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadSurahs);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QuranEvent.loadSurahs()';
}


}




/// @nodoc


class _LoadSurahDetails implements QuranEvent {
  const _LoadSurahDetails(this.surahNumber);
  

 final  int surahNumber;

/// Create a copy of QuranEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadSurahDetailsCopyWith<_LoadSurahDetails> get copyWith => __$LoadSurahDetailsCopyWithImpl<_LoadSurahDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadSurahDetails&&(identical(other.surahNumber, surahNumber) || other.surahNumber == surahNumber));
}


@override
int get hashCode => Object.hash(runtimeType,surahNumber);

@override
String toString() {
  return 'QuranEvent.loadSurahDetails(surahNumber: $surahNumber)';
}


}

/// @nodoc
abstract mixin class _$LoadSurahDetailsCopyWith<$Res> implements $QuranEventCopyWith<$Res> {
  factory _$LoadSurahDetailsCopyWith(_LoadSurahDetails value, $Res Function(_LoadSurahDetails) _then) = __$LoadSurahDetailsCopyWithImpl;
@useResult
$Res call({
 int surahNumber
});




}
/// @nodoc
class __$LoadSurahDetailsCopyWithImpl<$Res>
    implements _$LoadSurahDetailsCopyWith<$Res> {
  __$LoadSurahDetailsCopyWithImpl(this._self, this._then);

  final _LoadSurahDetails _self;
  final $Res Function(_LoadSurahDetails) _then;

/// Create a copy of QuranEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? surahNumber = null,}) {
  return _then(_LoadSurahDetails(
null == surahNumber ? _self.surahNumber : surahNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Search implements QuranEvent {
  const _Search(this.query);
  

 final  String query;

/// Create a copy of QuranEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchCopyWith<_Search> get copyWith => __$SearchCopyWithImpl<_Search>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Search&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'QuranEvent.search(query: $query)';
}


}

/// @nodoc
abstract mixin class _$SearchCopyWith<$Res> implements $QuranEventCopyWith<$Res> {
  factory _$SearchCopyWith(_Search value, $Res Function(_Search) _then) = __$SearchCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class __$SearchCopyWithImpl<$Res>
    implements _$SearchCopyWith<$Res> {
  __$SearchCopyWithImpl(this._self, this._then);

  final _Search _self;
  final $Res Function(_Search) _then;

/// Create a copy of QuranEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_Search(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$QuranState {

 bool get isLoading; List<Surah> get surahs; List<Ayah> get ayahs; Surah? get selectedSurah; String? get error; List<SearchResult> get searchResults;
/// Create a copy of QuranState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranStateCopyWith<QuranState> get copyWith => _$QuranStateCopyWithImpl<QuranState>(this as QuranState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.surahs, surahs)&&const DeepCollectionEquality().equals(other.ayahs, ayahs)&&(identical(other.selectedSurah, selectedSurah) || other.selectedSurah == selectedSurah)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.searchResults, searchResults));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(surahs),const DeepCollectionEquality().hash(ayahs),selectedSurah,error,const DeepCollectionEquality().hash(searchResults));

@override
String toString() {
  return 'QuranState(isLoading: $isLoading, surahs: $surahs, ayahs: $ayahs, selectedSurah: $selectedSurah, error: $error, searchResults: $searchResults)';
}


}

/// @nodoc
abstract mixin class $QuranStateCopyWith<$Res>  {
  factory $QuranStateCopyWith(QuranState value, $Res Function(QuranState) _then) = _$QuranStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Surah> surahs, List<Ayah> ayahs, Surah? selectedSurah, String? error, List<SearchResult> searchResults
});




}
/// @nodoc
class _$QuranStateCopyWithImpl<$Res>
    implements $QuranStateCopyWith<$Res> {
  _$QuranStateCopyWithImpl(this._self, this._then);

  final QuranState _self;
  final $Res Function(QuranState) _then;

/// Create a copy of QuranState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? surahs = null,Object? ayahs = null,Object? selectedSurah = freezed,Object? error = freezed,Object? searchResults = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,surahs: null == surahs ? _self.surahs : surahs // ignore: cast_nullable_to_non_nullable
as List<Surah>,ayahs: null == ayahs ? _self.ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<Ayah>,selectedSurah: freezed == selectedSurah ? _self.selectedSurah : selectedSurah // ignore: cast_nullable_to_non_nullable
as Surah?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self.searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranState].
extension QuranStatePatterns on QuranState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranState value)  $default,){
final _that = this;
switch (_that) {
case _QuranState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranState value)?  $default,){
final _that = this;
switch (_that) {
case _QuranState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<Surah> surahs,  List<Ayah> ayahs,  Surah? selectedSurah,  String? error,  List<SearchResult> searchResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranState() when $default != null:
return $default(_that.isLoading,_that.surahs,_that.ayahs,_that.selectedSurah,_that.error,_that.searchResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<Surah> surahs,  List<Ayah> ayahs,  Surah? selectedSurah,  String? error,  List<SearchResult> searchResults)  $default,) {final _that = this;
switch (_that) {
case _QuranState():
return $default(_that.isLoading,_that.surahs,_that.ayahs,_that.selectedSurah,_that.error,_that.searchResults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<Surah> surahs,  List<Ayah> ayahs,  Surah? selectedSurah,  String? error,  List<SearchResult> searchResults)?  $default,) {final _that = this;
switch (_that) {
case _QuranState() when $default != null:
return $default(_that.isLoading,_that.surahs,_that.ayahs,_that.selectedSurah,_that.error,_that.searchResults);case _:
  return null;

}
}

}

/// @nodoc


class _QuranState implements QuranState {
  const _QuranState({this.isLoading = false, final  List<Surah> surahs = const [], final  List<Ayah> ayahs = const [], this.selectedSurah, this.error, final  List<SearchResult> searchResults = const []}): _surahs = surahs,_ayahs = ayahs,_searchResults = searchResults;
  

@override@JsonKey() final  bool isLoading;
 final  List<Surah> _surahs;
@override@JsonKey() List<Surah> get surahs {
  if (_surahs is EqualUnmodifiableListView) return _surahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surahs);
}

 final  List<Ayah> _ayahs;
@override@JsonKey() List<Ayah> get ayahs {
  if (_ayahs is EqualUnmodifiableListView) return _ayahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ayahs);
}

@override final  Surah? selectedSurah;
@override final  String? error;
 final  List<SearchResult> _searchResults;
@override@JsonKey() List<SearchResult> get searchResults {
  if (_searchResults is EqualUnmodifiableListView) return _searchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchResults);
}


/// Create a copy of QuranState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranStateCopyWith<_QuranState> get copyWith => __$QuranStateCopyWithImpl<_QuranState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._surahs, _surahs)&&const DeepCollectionEquality().equals(other._ayahs, _ayahs)&&(identical(other.selectedSurah, selectedSurah) || other.selectedSurah == selectedSurah)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._searchResults, _searchResults));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_surahs),const DeepCollectionEquality().hash(_ayahs),selectedSurah,error,const DeepCollectionEquality().hash(_searchResults));

@override
String toString() {
  return 'QuranState(isLoading: $isLoading, surahs: $surahs, ayahs: $ayahs, selectedSurah: $selectedSurah, error: $error, searchResults: $searchResults)';
}


}

/// @nodoc
abstract mixin class _$QuranStateCopyWith<$Res> implements $QuranStateCopyWith<$Res> {
  factory _$QuranStateCopyWith(_QuranState value, $Res Function(_QuranState) _then) = __$QuranStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Surah> surahs, List<Ayah> ayahs, Surah? selectedSurah, String? error, List<SearchResult> searchResults
});




}
/// @nodoc
class __$QuranStateCopyWithImpl<$Res>
    implements _$QuranStateCopyWith<$Res> {
  __$QuranStateCopyWithImpl(this._self, this._then);

  final _QuranState _self;
  final $Res Function(_QuranState) _then;

/// Create a copy of QuranState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? surahs = null,Object? ayahs = null,Object? selectedSurah = freezed,Object? error = freezed,Object? searchResults = null,}) {
  return _then(_QuranState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,surahs: null == surahs ? _self._surahs : surahs // ignore: cast_nullable_to_non_nullable
as List<Surah>,ayahs: null == ayahs ? _self._ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<Ayah>,selectedSurah: freezed == selectedSurah ? _self.selectedSurah : selectedSurah // ignore: cast_nullable_to_non_nullable
as Surah?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self._searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,
  ));
}


}

// dart format on
