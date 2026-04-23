// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_symbol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuranSymbol {

 String get id; String get char; String get arabicName; String get brief; String get ruleSummary; int get difficulty; String get color; List<SymbolSource> get sources; List<SymbolExample> get examples;
/// Create a copy of QuranSymbol
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranSymbolCopyWith<QuranSymbol> get copyWith => _$QuranSymbolCopyWithImpl<QuranSymbol>(this as QuranSymbol, _$identity);

  /// Serializes this QuranSymbol to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranSymbol&&(identical(other.id, id) || other.id == id)&&(identical(other.char, char) || other.char == char)&&(identical(other.arabicName, arabicName) || other.arabicName == arabicName)&&(identical(other.brief, brief) || other.brief == brief)&&(identical(other.ruleSummary, ruleSummary) || other.ruleSummary == ruleSummary)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.sources, sources)&&const DeepCollectionEquality().equals(other.examples, examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,char,arabicName,brief,ruleSummary,difficulty,color,const DeepCollectionEquality().hash(sources),const DeepCollectionEquality().hash(examples));

@override
String toString() {
  return 'QuranSymbol(id: $id, char: $char, arabicName: $arabicName, brief: $brief, ruleSummary: $ruleSummary, difficulty: $difficulty, color: $color, sources: $sources, examples: $examples)';
}


}

/// @nodoc
abstract mixin class $QuranSymbolCopyWith<$Res>  {
  factory $QuranSymbolCopyWith(QuranSymbol value, $Res Function(QuranSymbol) _then) = _$QuranSymbolCopyWithImpl;
@useResult
$Res call({
 String id, String char, String arabicName, String brief, String ruleSummary, int difficulty, String color, List<SymbolSource> sources, List<SymbolExample> examples
});




}
/// @nodoc
class _$QuranSymbolCopyWithImpl<$Res>
    implements $QuranSymbolCopyWith<$Res> {
  _$QuranSymbolCopyWithImpl(this._self, this._then);

  final QuranSymbol _self;
  final $Res Function(QuranSymbol) _then;

/// Create a copy of QuranSymbol
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? char = null,Object? arabicName = null,Object? brief = null,Object? ruleSummary = null,Object? difficulty = null,Object? color = null,Object? sources = null,Object? examples = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,char: null == char ? _self.char : char // ignore: cast_nullable_to_non_nullable
as String,arabicName: null == arabicName ? _self.arabicName : arabicName // ignore: cast_nullable_to_non_nullable
as String,brief: null == brief ? _self.brief : brief // ignore: cast_nullable_to_non_nullable
as String,ruleSummary: null == ruleSummary ? _self.ruleSummary : ruleSummary // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<SymbolSource>,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<SymbolExample>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranSymbol].
extension QuranSymbolPatterns on QuranSymbol {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranSymbol value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranSymbol() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranSymbol value)  $default,){
final _that = this;
switch (_that) {
case _QuranSymbol():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranSymbol value)?  $default,){
final _that = this;
switch (_that) {
case _QuranSymbol() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String char,  String arabicName,  String brief,  String ruleSummary,  int difficulty,  String color,  List<SymbolSource> sources,  List<SymbolExample> examples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranSymbol() when $default != null:
return $default(_that.id,_that.char,_that.arabicName,_that.brief,_that.ruleSummary,_that.difficulty,_that.color,_that.sources,_that.examples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String char,  String arabicName,  String brief,  String ruleSummary,  int difficulty,  String color,  List<SymbolSource> sources,  List<SymbolExample> examples)  $default,) {final _that = this;
switch (_that) {
case _QuranSymbol():
return $default(_that.id,_that.char,_that.arabicName,_that.brief,_that.ruleSummary,_that.difficulty,_that.color,_that.sources,_that.examples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String char,  String arabicName,  String brief,  String ruleSummary,  int difficulty,  String color,  List<SymbolSource> sources,  List<SymbolExample> examples)?  $default,) {final _that = this;
switch (_that) {
case _QuranSymbol() when $default != null:
return $default(_that.id,_that.char,_that.arabicName,_that.brief,_that.ruleSummary,_that.difficulty,_that.color,_that.sources,_that.examples);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _QuranSymbol extends QuranSymbol {
  const _QuranSymbol({required this.id, required this.char, required this.arabicName, required this.brief, required this.ruleSummary, required this.difficulty, required this.color, required final  List<SymbolSource> sources, final  List<SymbolExample> examples = const []}): _sources = sources,_examples = examples,super._();
  factory _QuranSymbol.fromJson(Map<String, dynamic> json) => _$QuranSymbolFromJson(json);

@override final  String id;
@override final  String char;
@override final  String arabicName;
@override final  String brief;
@override final  String ruleSummary;
@override final  int difficulty;
@override final  String color;
 final  List<SymbolSource> _sources;
@override List<SymbolSource> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

 final  List<SymbolExample> _examples;
@override@JsonKey() List<SymbolExample> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}


/// Create a copy of QuranSymbol
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranSymbolCopyWith<_QuranSymbol> get copyWith => __$QuranSymbolCopyWithImpl<_QuranSymbol>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranSymbolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranSymbol&&(identical(other.id, id) || other.id == id)&&(identical(other.char, char) || other.char == char)&&(identical(other.arabicName, arabicName) || other.arabicName == arabicName)&&(identical(other.brief, brief) || other.brief == brief)&&(identical(other.ruleSummary, ruleSummary) || other.ruleSummary == ruleSummary)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._sources, _sources)&&const DeepCollectionEquality().equals(other._examples, _examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,char,arabicName,brief,ruleSummary,difficulty,color,const DeepCollectionEquality().hash(_sources),const DeepCollectionEquality().hash(_examples));

@override
String toString() {
  return 'QuranSymbol(id: $id, char: $char, arabicName: $arabicName, brief: $brief, ruleSummary: $ruleSummary, difficulty: $difficulty, color: $color, sources: $sources, examples: $examples)';
}


}

/// @nodoc
abstract mixin class _$QuranSymbolCopyWith<$Res> implements $QuranSymbolCopyWith<$Res> {
  factory _$QuranSymbolCopyWith(_QuranSymbol value, $Res Function(_QuranSymbol) _then) = __$QuranSymbolCopyWithImpl;
@override @useResult
$Res call({
 String id, String char, String arabicName, String brief, String ruleSummary, int difficulty, String color, List<SymbolSource> sources, List<SymbolExample> examples
});




}
/// @nodoc
class __$QuranSymbolCopyWithImpl<$Res>
    implements _$QuranSymbolCopyWith<$Res> {
  __$QuranSymbolCopyWithImpl(this._self, this._then);

  final _QuranSymbol _self;
  final $Res Function(_QuranSymbol) _then;

/// Create a copy of QuranSymbol
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? char = null,Object? arabicName = null,Object? brief = null,Object? ruleSummary = null,Object? difficulty = null,Object? color = null,Object? sources = null,Object? examples = null,}) {
  return _then(_QuranSymbol(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,char: null == char ? _self.char : char // ignore: cast_nullable_to_non_nullable
as String,arabicName: null == arabicName ? _self.arabicName : arabicName // ignore: cast_nullable_to_non_nullable
as String,brief: null == brief ? _self.brief : brief // ignore: cast_nullable_to_non_nullable
as String,ruleSummary: null == ruleSummary ? _self.ruleSummary : ruleSummary // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<SymbolSource>,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<SymbolExample>,
  ));
}


}


/// @nodoc
mixin _$SymbolSource {

 String get name;@JsonKey(name: 'type') String get sourceType;// 'book', 'website', 'video'
@JsonKey(name: 'text') String get content;
/// Create a copy of SymbolSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SymbolSourceCopyWith<SymbolSource> get copyWith => _$SymbolSourceCopyWithImpl<SymbolSource>(this as SymbolSource, _$identity);

  /// Serializes this SymbolSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SymbolSource&&(identical(other.name, name) || other.name == name)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sourceType,content);

@override
String toString() {
  return 'SymbolSource(name: $name, sourceType: $sourceType, content: $content)';
}


}

/// @nodoc
abstract mixin class $SymbolSourceCopyWith<$Res>  {
  factory $SymbolSourceCopyWith(SymbolSource value, $Res Function(SymbolSource) _then) = _$SymbolSourceCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'type') String sourceType,@JsonKey(name: 'text') String content
});




}
/// @nodoc
class _$SymbolSourceCopyWithImpl<$Res>
    implements $SymbolSourceCopyWith<$Res> {
  _$SymbolSourceCopyWithImpl(this._self, this._then);

  final SymbolSource _self;
  final $Res Function(SymbolSource) _then;

/// Create a copy of SymbolSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? sourceType = null,Object? content = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SymbolSource].
extension SymbolSourcePatterns on SymbolSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SymbolSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SymbolSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SymbolSource value)  $default,){
final _that = this;
switch (_that) {
case _SymbolSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SymbolSource value)?  $default,){
final _that = this;
switch (_that) {
case _SymbolSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'type')  String sourceType, @JsonKey(name: 'text')  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SymbolSource() when $default != null:
return $default(_that.name,_that.sourceType,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'type')  String sourceType, @JsonKey(name: 'text')  String content)  $default,) {final _that = this;
switch (_that) {
case _SymbolSource():
return $default(_that.name,_that.sourceType,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'type')  String sourceType, @JsonKey(name: 'text')  String content)?  $default,) {final _that = this;
switch (_that) {
case _SymbolSource() when $default != null:
return $default(_that.name,_that.sourceType,_that.content);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SymbolSource extends SymbolSource {
  const _SymbolSource({required this.name, @JsonKey(name: 'type') required this.sourceType, @JsonKey(name: 'text') required this.content}): super._();
  factory _SymbolSource.fromJson(Map<String, dynamic> json) => _$SymbolSourceFromJson(json);

@override final  String name;
@override@JsonKey(name: 'type') final  String sourceType;
// 'book', 'website', 'video'
@override@JsonKey(name: 'text') final  String content;

/// Create a copy of SymbolSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SymbolSourceCopyWith<_SymbolSource> get copyWith => __$SymbolSourceCopyWithImpl<_SymbolSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SymbolSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SymbolSource&&(identical(other.name, name) || other.name == name)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sourceType,content);

@override
String toString() {
  return 'SymbolSource(name: $name, sourceType: $sourceType, content: $content)';
}


}

/// @nodoc
abstract mixin class _$SymbolSourceCopyWith<$Res> implements $SymbolSourceCopyWith<$Res> {
  factory _$SymbolSourceCopyWith(_SymbolSource value, $Res Function(_SymbolSource) _then) = __$SymbolSourceCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'type') String sourceType,@JsonKey(name: 'text') String content
});




}
/// @nodoc
class __$SymbolSourceCopyWithImpl<$Res>
    implements _$SymbolSourceCopyWith<$Res> {
  __$SymbolSourceCopyWithImpl(this._self, this._then);

  final _SymbolSource _self;
  final $Res Function(_SymbolSource) _then;

/// Create a copy of SymbolSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? sourceType = null,Object? content = null,}) {
  return _then(_SymbolSource(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SymbolExample {

 int get surah; int get ayah; String? get context;
/// Create a copy of SymbolExample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SymbolExampleCopyWith<SymbolExample> get copyWith => _$SymbolExampleCopyWithImpl<SymbolExample>(this as SymbolExample, _$identity);

  /// Serializes this SymbolExample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SymbolExample&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.context, context) || other.context == context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surah,ayah,context);

@override
String toString() {
  return 'SymbolExample(surah: $surah, ayah: $ayah, context: $context)';
}


}

/// @nodoc
abstract mixin class $SymbolExampleCopyWith<$Res>  {
  factory $SymbolExampleCopyWith(SymbolExample value, $Res Function(SymbolExample) _then) = _$SymbolExampleCopyWithImpl;
@useResult
$Res call({
 int surah, int ayah, String? context
});




}
/// @nodoc
class _$SymbolExampleCopyWithImpl<$Res>
    implements $SymbolExampleCopyWith<$Res> {
  _$SymbolExampleCopyWithImpl(this._self, this._then);

  final SymbolExample _self;
  final $Res Function(SymbolExample) _then;

/// Create a copy of SymbolExample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surah = null,Object? ayah = null,Object? context = freezed,}) {
  return _then(_self.copyWith(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SymbolExample].
extension SymbolExamplePatterns on SymbolExample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SymbolExample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SymbolExample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SymbolExample value)  $default,){
final _that = this;
switch (_that) {
case _SymbolExample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SymbolExample value)?  $default,){
final _that = this;
switch (_that) {
case _SymbolExample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surah,  int ayah,  String? context)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SymbolExample() when $default != null:
return $default(_that.surah,_that.ayah,_that.context);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surah,  int ayah,  String? context)  $default,) {final _that = this;
switch (_that) {
case _SymbolExample():
return $default(_that.surah,_that.ayah,_that.context);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surah,  int ayah,  String? context)?  $default,) {final _that = this;
switch (_that) {
case _SymbolExample() when $default != null:
return $default(_that.surah,_that.ayah,_that.context);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SymbolExample extends SymbolExample {
  const _SymbolExample({required this.surah, required this.ayah, this.context}): super._();
  factory _SymbolExample.fromJson(Map<String, dynamic> json) => _$SymbolExampleFromJson(json);

@override final  int surah;
@override final  int ayah;
@override final  String? context;

/// Create a copy of SymbolExample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SymbolExampleCopyWith<_SymbolExample> get copyWith => __$SymbolExampleCopyWithImpl<_SymbolExample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SymbolExampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SymbolExample&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.context, context) || other.context == context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surah,ayah,context);

@override
String toString() {
  return 'SymbolExample(surah: $surah, ayah: $ayah, context: $context)';
}


}

/// @nodoc
abstract mixin class _$SymbolExampleCopyWith<$Res> implements $SymbolExampleCopyWith<$Res> {
  factory _$SymbolExampleCopyWith(_SymbolExample value, $Res Function(_SymbolExample) _then) = __$SymbolExampleCopyWithImpl;
@override @useResult
$Res call({
 int surah, int ayah, String? context
});




}
/// @nodoc
class __$SymbolExampleCopyWithImpl<$Res>
    implements _$SymbolExampleCopyWith<$Res> {
  __$SymbolExampleCopyWithImpl(this._self, this._then);

  final _SymbolExample _self;
  final $Res Function(_SymbolExample) _then;

/// Create a copy of SymbolExample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surah = null,Object? ayah = null,Object? context = freezed,}) {
  return _then(_SymbolExample(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
