// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasbih_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TasbihItem {

 String get id; String get arabic; String get transliteration; String get translation; int get order;@JsonKey(name: 'target_count') int get targetCount; String? get source; String? get virtue; String? get time;
/// Create a copy of TasbihItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasbihItemCopyWith<TasbihItem> get copyWith => _$TasbihItemCopyWithImpl<TasbihItem>(this as TasbihItem, _$identity);

  /// Serializes this TasbihItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasbihItem&&(identical(other.id, id) || other.id == id)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.order, order) || other.order == order)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.source, source) || other.source == source)&&(identical(other.virtue, virtue) || other.virtue == virtue)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,arabic,transliteration,translation,order,targetCount,source,virtue,time);

@override
String toString() {
  return 'TasbihItem(id: $id, arabic: $arabic, transliteration: $transliteration, translation: $translation, order: $order, targetCount: $targetCount, source: $source, virtue: $virtue, time: $time)';
}


}

/// @nodoc
abstract mixin class $TasbihItemCopyWith<$Res>  {
  factory $TasbihItemCopyWith(TasbihItem value, $Res Function(TasbihItem) _then) = _$TasbihItemCopyWithImpl;
@useResult
$Res call({
 String id, String arabic, String transliteration, String translation, int order,@JsonKey(name: 'target_count') int targetCount, String? source, String? virtue, String? time
});




}
/// @nodoc
class _$TasbihItemCopyWithImpl<$Res>
    implements $TasbihItemCopyWith<$Res> {
  _$TasbihItemCopyWithImpl(this._self, this._then);

  final TasbihItem _self;
  final $Res Function(TasbihItem) _then;

/// Create a copy of TasbihItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? arabic = null,Object? transliteration = null,Object? translation = null,Object? order = null,Object? targetCount = null,Object? source = freezed,Object? virtue = freezed,Object? time = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,transliteration: null == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,virtue: freezed == virtue ? _self.virtue : virtue // ignore: cast_nullable_to_non_nullable
as String?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TasbihItem].
extension TasbihItemPatterns on TasbihItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasbihItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasbihItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasbihItem value)  $default,){
final _that = this;
switch (_that) {
case _TasbihItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasbihItem value)?  $default,){
final _that = this;
switch (_that) {
case _TasbihItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String arabic,  String transliteration,  String translation,  int order, @JsonKey(name: 'target_count')  int targetCount,  String? source,  String? virtue,  String? time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasbihItem() when $default != null:
return $default(_that.id,_that.arabic,_that.transliteration,_that.translation,_that.order,_that.targetCount,_that.source,_that.virtue,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String arabic,  String transliteration,  String translation,  int order, @JsonKey(name: 'target_count')  int targetCount,  String? source,  String? virtue,  String? time)  $default,) {final _that = this;
switch (_that) {
case _TasbihItem():
return $default(_that.id,_that.arabic,_that.transliteration,_that.translation,_that.order,_that.targetCount,_that.source,_that.virtue,_that.time);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String arabic,  String transliteration,  String translation,  int order, @JsonKey(name: 'target_count')  int targetCount,  String? source,  String? virtue,  String? time)?  $default,) {final _that = this;
switch (_that) {
case _TasbihItem() when $default != null:
return $default(_that.id,_that.arabic,_that.transliteration,_that.translation,_that.order,_that.targetCount,_that.source,_that.virtue,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TasbihItem implements TasbihItem {
  const _TasbihItem({required this.id, required this.arabic, required this.transliteration, required this.translation, this.order = 0, @JsonKey(name: 'target_count') this.targetCount = 33, this.source, this.virtue, this.time});
  factory _TasbihItem.fromJson(Map<String, dynamic> json) => _$TasbihItemFromJson(json);

@override final  String id;
@override final  String arabic;
@override final  String transliteration;
@override final  String translation;
@override@JsonKey() final  int order;
@override@JsonKey(name: 'target_count') final  int targetCount;
@override final  String? source;
@override final  String? virtue;
@override final  String? time;

/// Create a copy of TasbihItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasbihItemCopyWith<_TasbihItem> get copyWith => __$TasbihItemCopyWithImpl<_TasbihItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TasbihItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasbihItem&&(identical(other.id, id) || other.id == id)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.order, order) || other.order == order)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.source, source) || other.source == source)&&(identical(other.virtue, virtue) || other.virtue == virtue)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,arabic,transliteration,translation,order,targetCount,source,virtue,time);

@override
String toString() {
  return 'TasbihItem(id: $id, arabic: $arabic, transliteration: $transliteration, translation: $translation, order: $order, targetCount: $targetCount, source: $source, virtue: $virtue, time: $time)';
}


}

/// @nodoc
abstract mixin class _$TasbihItemCopyWith<$Res> implements $TasbihItemCopyWith<$Res> {
  factory _$TasbihItemCopyWith(_TasbihItem value, $Res Function(_TasbihItem) _then) = __$TasbihItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String arabic, String transliteration, String translation, int order,@JsonKey(name: 'target_count') int targetCount, String? source, String? virtue, String? time
});




}
/// @nodoc
class __$TasbihItemCopyWithImpl<$Res>
    implements _$TasbihItemCopyWith<$Res> {
  __$TasbihItemCopyWithImpl(this._self, this._then);

  final _TasbihItem _self;
  final $Res Function(_TasbihItem) _then;

/// Create a copy of TasbihItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? arabic = null,Object? transliteration = null,Object? translation = null,Object? order = null,Object? targetCount = null,Object? source = freezed,Object? virtue = freezed,Object? time = freezed,}) {
  return _then(_TasbihItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,transliteration: null == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,virtue: freezed == virtue ? _self.virtue : virtue // ignore: cast_nullable_to_non_nullable
as String?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CompletionDua {

 String get id; String get title; String get arabic; String get transliteration; String get translation; String? get source;@JsonKey(name: 'optional_recitation') String? get optionalRecitation; String? get note;
/// Create a copy of CompletionDua
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletionDuaCopyWith<CompletionDua> get copyWith => _$CompletionDuaCopyWithImpl<CompletionDua>(this as CompletionDua, _$identity);

  /// Serializes this CompletionDua to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletionDua&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.source, source) || other.source == source)&&(identical(other.optionalRecitation, optionalRecitation) || other.optionalRecitation == optionalRecitation)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,arabic,transliteration,translation,source,optionalRecitation,note);

@override
String toString() {
  return 'CompletionDua(id: $id, title: $title, arabic: $arabic, transliteration: $transliteration, translation: $translation, source: $source, optionalRecitation: $optionalRecitation, note: $note)';
}


}

/// @nodoc
abstract mixin class $CompletionDuaCopyWith<$Res>  {
  factory $CompletionDuaCopyWith(CompletionDua value, $Res Function(CompletionDua) _then) = _$CompletionDuaCopyWithImpl;
@useResult
$Res call({
 String id, String title, String arabic, String transliteration, String translation, String? source,@JsonKey(name: 'optional_recitation') String? optionalRecitation, String? note
});




}
/// @nodoc
class _$CompletionDuaCopyWithImpl<$Res>
    implements $CompletionDuaCopyWith<$Res> {
  _$CompletionDuaCopyWithImpl(this._self, this._then);

  final CompletionDua _self;
  final $Res Function(CompletionDua) _then;

/// Create a copy of CompletionDua
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? arabic = null,Object? transliteration = null,Object? translation = null,Object? source = freezed,Object? optionalRecitation = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,transliteration: null == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,optionalRecitation: freezed == optionalRecitation ? _self.optionalRecitation : optionalRecitation // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletionDua].
extension CompletionDuaPatterns on CompletionDua {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletionDua value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletionDua() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletionDua value)  $default,){
final _that = this;
switch (_that) {
case _CompletionDua():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletionDua value)?  $default,){
final _that = this;
switch (_that) {
case _CompletionDua() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String arabic,  String transliteration,  String translation,  String? source, @JsonKey(name: 'optional_recitation')  String? optionalRecitation,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletionDua() when $default != null:
return $default(_that.id,_that.title,_that.arabic,_that.transliteration,_that.translation,_that.source,_that.optionalRecitation,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String arabic,  String transliteration,  String translation,  String? source, @JsonKey(name: 'optional_recitation')  String? optionalRecitation,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CompletionDua():
return $default(_that.id,_that.title,_that.arabic,_that.transliteration,_that.translation,_that.source,_that.optionalRecitation,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String arabic,  String transliteration,  String translation,  String? source, @JsonKey(name: 'optional_recitation')  String? optionalRecitation,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CompletionDua() when $default != null:
return $default(_that.id,_that.title,_that.arabic,_that.transliteration,_that.translation,_that.source,_that.optionalRecitation,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompletionDua implements CompletionDua {
  const _CompletionDua({required this.id, required this.title, required this.arabic, required this.transliteration, required this.translation, this.source, @JsonKey(name: 'optional_recitation') this.optionalRecitation, this.note});
  factory _CompletionDua.fromJson(Map<String, dynamic> json) => _$CompletionDuaFromJson(json);

@override final  String id;
@override final  String title;
@override final  String arabic;
@override final  String transliteration;
@override final  String translation;
@override final  String? source;
@override@JsonKey(name: 'optional_recitation') final  String? optionalRecitation;
@override final  String? note;

/// Create a copy of CompletionDua
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletionDuaCopyWith<_CompletionDua> get copyWith => __$CompletionDuaCopyWithImpl<_CompletionDua>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompletionDuaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletionDua&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.source, source) || other.source == source)&&(identical(other.optionalRecitation, optionalRecitation) || other.optionalRecitation == optionalRecitation)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,arabic,transliteration,translation,source,optionalRecitation,note);

@override
String toString() {
  return 'CompletionDua(id: $id, title: $title, arabic: $arabic, transliteration: $transliteration, translation: $translation, source: $source, optionalRecitation: $optionalRecitation, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CompletionDuaCopyWith<$Res> implements $CompletionDuaCopyWith<$Res> {
  factory _$CompletionDuaCopyWith(_CompletionDua value, $Res Function(_CompletionDua) _then) = __$CompletionDuaCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String arabic, String transliteration, String translation, String? source,@JsonKey(name: 'optional_recitation') String? optionalRecitation, String? note
});




}
/// @nodoc
class __$CompletionDuaCopyWithImpl<$Res>
    implements _$CompletionDuaCopyWith<$Res> {
  __$CompletionDuaCopyWithImpl(this._self, this._then);

  final _CompletionDua _self;
  final $Res Function(_CompletionDua) _then;

/// Create a copy of CompletionDua
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? arabic = null,Object? transliteration = null,Object? translation = null,Object? source = freezed,Object? optionalRecitation = freezed,Object? note = freezed,}) {
  return _then(_CompletionDua(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,transliteration: null == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,optionalRecitation: freezed == optionalRecitation ? _self.optionalRecitation : optionalRecitation // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TasbihCategory {

 String get id; String get name; String get description;@JsonKey(name: 'sequence_mode') String get sequenceMode; List<TasbihItem> get items;@JsonKey(name: 'default_completion_dua_id') String? get defaultCompletionDuaId; int get cycles;@JsonKey(name: 'counts_per_cycle') int get countsPerCycle;@JsonKey(name: 'completion_trigger') int get completionTrigger;@JsonKey(name: 'is_editable') bool get isEditable;@JsonKey(name: 'max_target_count') int get maxTargetCount;@JsonKey(name: 'allow_completion_dua') bool get allowCompletionDua;
/// Create a copy of TasbihCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasbihCategoryCopyWith<TasbihCategory> get copyWith => _$TasbihCategoryCopyWithImpl<TasbihCategory>(this as TasbihCategory, _$identity);

  /// Serializes this TasbihCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasbihCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sequenceMode, sequenceMode) || other.sequenceMode == sequenceMode)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.defaultCompletionDuaId, defaultCompletionDuaId) || other.defaultCompletionDuaId == defaultCompletionDuaId)&&(identical(other.cycles, cycles) || other.cycles == cycles)&&(identical(other.countsPerCycle, countsPerCycle) || other.countsPerCycle == countsPerCycle)&&(identical(other.completionTrigger, completionTrigger) || other.completionTrigger == completionTrigger)&&(identical(other.isEditable, isEditable) || other.isEditable == isEditable)&&(identical(other.maxTargetCount, maxTargetCount) || other.maxTargetCount == maxTargetCount)&&(identical(other.allowCompletionDua, allowCompletionDua) || other.allowCompletionDua == allowCompletionDua));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,sequenceMode,const DeepCollectionEquality().hash(items),defaultCompletionDuaId,cycles,countsPerCycle,completionTrigger,isEditable,maxTargetCount,allowCompletionDua);

@override
String toString() {
  return 'TasbihCategory(id: $id, name: $name, description: $description, sequenceMode: $sequenceMode, items: $items, defaultCompletionDuaId: $defaultCompletionDuaId, cycles: $cycles, countsPerCycle: $countsPerCycle, completionTrigger: $completionTrigger, isEditable: $isEditable, maxTargetCount: $maxTargetCount, allowCompletionDua: $allowCompletionDua)';
}


}

/// @nodoc
abstract mixin class $TasbihCategoryCopyWith<$Res>  {
  factory $TasbihCategoryCopyWith(TasbihCategory value, $Res Function(TasbihCategory) _then) = _$TasbihCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description,@JsonKey(name: 'sequence_mode') String sequenceMode, List<TasbihItem> items,@JsonKey(name: 'default_completion_dua_id') String? defaultCompletionDuaId, int cycles,@JsonKey(name: 'counts_per_cycle') int countsPerCycle,@JsonKey(name: 'completion_trigger') int completionTrigger,@JsonKey(name: 'is_editable') bool isEditable,@JsonKey(name: 'max_target_count') int maxTargetCount,@JsonKey(name: 'allow_completion_dua') bool allowCompletionDua
});




}
/// @nodoc
class _$TasbihCategoryCopyWithImpl<$Res>
    implements $TasbihCategoryCopyWith<$Res> {
  _$TasbihCategoryCopyWithImpl(this._self, this._then);

  final TasbihCategory _self;
  final $Res Function(TasbihCategory) _then;

/// Create a copy of TasbihCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? sequenceMode = null,Object? items = null,Object? defaultCompletionDuaId = freezed,Object? cycles = null,Object? countsPerCycle = null,Object? completionTrigger = null,Object? isEditable = null,Object? maxTargetCount = null,Object? allowCompletionDua = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sequenceMode: null == sequenceMode ? _self.sequenceMode : sequenceMode // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TasbihItem>,defaultCompletionDuaId: freezed == defaultCompletionDuaId ? _self.defaultCompletionDuaId : defaultCompletionDuaId // ignore: cast_nullable_to_non_nullable
as String?,cycles: null == cycles ? _self.cycles : cycles // ignore: cast_nullable_to_non_nullable
as int,countsPerCycle: null == countsPerCycle ? _self.countsPerCycle : countsPerCycle // ignore: cast_nullable_to_non_nullable
as int,completionTrigger: null == completionTrigger ? _self.completionTrigger : completionTrigger // ignore: cast_nullable_to_non_nullable
as int,isEditable: null == isEditable ? _self.isEditable : isEditable // ignore: cast_nullable_to_non_nullable
as bool,maxTargetCount: null == maxTargetCount ? _self.maxTargetCount : maxTargetCount // ignore: cast_nullable_to_non_nullable
as int,allowCompletionDua: null == allowCompletionDua ? _self.allowCompletionDua : allowCompletionDua // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TasbihCategory].
extension TasbihCategoryPatterns on TasbihCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasbihCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasbihCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasbihCategory value)  $default,){
final _that = this;
switch (_that) {
case _TasbihCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasbihCategory value)?  $default,){
final _that = this;
switch (_that) {
case _TasbihCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description, @JsonKey(name: 'sequence_mode')  String sequenceMode,  List<TasbihItem> items, @JsonKey(name: 'default_completion_dua_id')  String? defaultCompletionDuaId,  int cycles, @JsonKey(name: 'counts_per_cycle')  int countsPerCycle, @JsonKey(name: 'completion_trigger')  int completionTrigger, @JsonKey(name: 'is_editable')  bool isEditable, @JsonKey(name: 'max_target_count')  int maxTargetCount, @JsonKey(name: 'allow_completion_dua')  bool allowCompletionDua)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasbihCategory() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.sequenceMode,_that.items,_that.defaultCompletionDuaId,_that.cycles,_that.countsPerCycle,_that.completionTrigger,_that.isEditable,_that.maxTargetCount,_that.allowCompletionDua);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description, @JsonKey(name: 'sequence_mode')  String sequenceMode,  List<TasbihItem> items, @JsonKey(name: 'default_completion_dua_id')  String? defaultCompletionDuaId,  int cycles, @JsonKey(name: 'counts_per_cycle')  int countsPerCycle, @JsonKey(name: 'completion_trigger')  int completionTrigger, @JsonKey(name: 'is_editable')  bool isEditable, @JsonKey(name: 'max_target_count')  int maxTargetCount, @JsonKey(name: 'allow_completion_dua')  bool allowCompletionDua)  $default,) {final _that = this;
switch (_that) {
case _TasbihCategory():
return $default(_that.id,_that.name,_that.description,_that.sequenceMode,_that.items,_that.defaultCompletionDuaId,_that.cycles,_that.countsPerCycle,_that.completionTrigger,_that.isEditable,_that.maxTargetCount,_that.allowCompletionDua);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description, @JsonKey(name: 'sequence_mode')  String sequenceMode,  List<TasbihItem> items, @JsonKey(name: 'default_completion_dua_id')  String? defaultCompletionDuaId,  int cycles, @JsonKey(name: 'counts_per_cycle')  int countsPerCycle, @JsonKey(name: 'completion_trigger')  int completionTrigger, @JsonKey(name: 'is_editable')  bool isEditable, @JsonKey(name: 'max_target_count')  int maxTargetCount, @JsonKey(name: 'allow_completion_dua')  bool allowCompletionDua)?  $default,) {final _that = this;
switch (_that) {
case _TasbihCategory() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.sequenceMode,_that.items,_that.defaultCompletionDuaId,_that.cycles,_that.countsPerCycle,_that.completionTrigger,_that.isEditable,_that.maxTargetCount,_that.allowCompletionDua);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TasbihCategory implements TasbihCategory {
  const _TasbihCategory({required this.id, required this.name, required this.description, @JsonKey(name: 'sequence_mode') required this.sequenceMode, final  List<TasbihItem> items = const [], @JsonKey(name: 'default_completion_dua_id') this.defaultCompletionDuaId, this.cycles = 1, @JsonKey(name: 'counts_per_cycle') this.countsPerCycle = 33, @JsonKey(name: 'completion_trigger') this.completionTrigger = 99, @JsonKey(name: 'is_editable') this.isEditable = false, @JsonKey(name: 'max_target_count') this.maxTargetCount = 1000, @JsonKey(name: 'allow_completion_dua') this.allowCompletionDua = false}): _items = items;
  factory _TasbihCategory.fromJson(Map<String, dynamic> json) => _$TasbihCategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override@JsonKey(name: 'sequence_mode') final  String sequenceMode;
 final  List<TasbihItem> _items;
@override@JsonKey() List<TasbihItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'default_completion_dua_id') final  String? defaultCompletionDuaId;
@override@JsonKey() final  int cycles;
@override@JsonKey(name: 'counts_per_cycle') final  int countsPerCycle;
@override@JsonKey(name: 'completion_trigger') final  int completionTrigger;
@override@JsonKey(name: 'is_editable') final  bool isEditable;
@override@JsonKey(name: 'max_target_count') final  int maxTargetCount;
@override@JsonKey(name: 'allow_completion_dua') final  bool allowCompletionDua;

/// Create a copy of TasbihCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasbihCategoryCopyWith<_TasbihCategory> get copyWith => __$TasbihCategoryCopyWithImpl<_TasbihCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TasbihCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasbihCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sequenceMode, sequenceMode) || other.sequenceMode == sequenceMode)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.defaultCompletionDuaId, defaultCompletionDuaId) || other.defaultCompletionDuaId == defaultCompletionDuaId)&&(identical(other.cycles, cycles) || other.cycles == cycles)&&(identical(other.countsPerCycle, countsPerCycle) || other.countsPerCycle == countsPerCycle)&&(identical(other.completionTrigger, completionTrigger) || other.completionTrigger == completionTrigger)&&(identical(other.isEditable, isEditable) || other.isEditable == isEditable)&&(identical(other.maxTargetCount, maxTargetCount) || other.maxTargetCount == maxTargetCount)&&(identical(other.allowCompletionDua, allowCompletionDua) || other.allowCompletionDua == allowCompletionDua));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,sequenceMode,const DeepCollectionEquality().hash(_items),defaultCompletionDuaId,cycles,countsPerCycle,completionTrigger,isEditable,maxTargetCount,allowCompletionDua);

@override
String toString() {
  return 'TasbihCategory(id: $id, name: $name, description: $description, sequenceMode: $sequenceMode, items: $items, defaultCompletionDuaId: $defaultCompletionDuaId, cycles: $cycles, countsPerCycle: $countsPerCycle, completionTrigger: $completionTrigger, isEditable: $isEditable, maxTargetCount: $maxTargetCount, allowCompletionDua: $allowCompletionDua)';
}


}

/// @nodoc
abstract mixin class _$TasbihCategoryCopyWith<$Res> implements $TasbihCategoryCopyWith<$Res> {
  factory _$TasbihCategoryCopyWith(_TasbihCategory value, $Res Function(_TasbihCategory) _then) = __$TasbihCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description,@JsonKey(name: 'sequence_mode') String sequenceMode, List<TasbihItem> items,@JsonKey(name: 'default_completion_dua_id') String? defaultCompletionDuaId, int cycles,@JsonKey(name: 'counts_per_cycle') int countsPerCycle,@JsonKey(name: 'completion_trigger') int completionTrigger,@JsonKey(name: 'is_editable') bool isEditable,@JsonKey(name: 'max_target_count') int maxTargetCount,@JsonKey(name: 'allow_completion_dua') bool allowCompletionDua
});




}
/// @nodoc
class __$TasbihCategoryCopyWithImpl<$Res>
    implements _$TasbihCategoryCopyWith<$Res> {
  __$TasbihCategoryCopyWithImpl(this._self, this._then);

  final _TasbihCategory _self;
  final $Res Function(_TasbihCategory) _then;

/// Create a copy of TasbihCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? sequenceMode = null,Object? items = null,Object? defaultCompletionDuaId = freezed,Object? cycles = null,Object? countsPerCycle = null,Object? completionTrigger = null,Object? isEditable = null,Object? maxTargetCount = null,Object? allowCompletionDua = null,}) {
  return _then(_TasbihCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sequenceMode: null == sequenceMode ? _self.sequenceMode : sequenceMode // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TasbihItem>,defaultCompletionDuaId: freezed == defaultCompletionDuaId ? _self.defaultCompletionDuaId : defaultCompletionDuaId // ignore: cast_nullable_to_non_nullable
as String?,cycles: null == cycles ? _self.cycles : cycles // ignore: cast_nullable_to_non_nullable
as int,countsPerCycle: null == countsPerCycle ? _self.countsPerCycle : countsPerCycle // ignore: cast_nullable_to_non_nullable
as int,completionTrigger: null == completionTrigger ? _self.completionTrigger : completionTrigger // ignore: cast_nullable_to_non_nullable
as int,isEditable: null == isEditable ? _self.isEditable : isEditable // ignore: cast_nullable_to_non_nullable
as bool,maxTargetCount: null == maxTargetCount ? _self.maxTargetCount : maxTargetCount // ignore: cast_nullable_to_non_nullable
as int,allowCompletionDua: null == allowCompletionDua ? _self.allowCompletionDua : allowCompletionDua // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TasbihData {

@JsonKey(name: 'completion_duas') List<CompletionDua> get completionDuas;@JsonKey(name: 'tasbih_categories') List<TasbihCategory> get categories; TasbihSettings get settings;
/// Create a copy of TasbihData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasbihDataCopyWith<TasbihData> get copyWith => _$TasbihDataCopyWithImpl<TasbihData>(this as TasbihData, _$identity);

  /// Serializes this TasbihData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasbihData&&const DeepCollectionEquality().equals(other.completionDuas, completionDuas)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(completionDuas),const DeepCollectionEquality().hash(categories),settings);

@override
String toString() {
  return 'TasbihData(completionDuas: $completionDuas, categories: $categories, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $TasbihDataCopyWith<$Res>  {
  factory $TasbihDataCopyWith(TasbihData value, $Res Function(TasbihData) _then) = _$TasbihDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'completion_duas') List<CompletionDua> completionDuas,@JsonKey(name: 'tasbih_categories') List<TasbihCategory> categories, TasbihSettings settings
});


$TasbihSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$TasbihDataCopyWithImpl<$Res>
    implements $TasbihDataCopyWith<$Res> {
  _$TasbihDataCopyWithImpl(this._self, this._then);

  final TasbihData _self;
  final $Res Function(TasbihData) _then;

/// Create a copy of TasbihData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completionDuas = null,Object? categories = null,Object? settings = null,}) {
  return _then(_self.copyWith(
completionDuas: null == completionDuas ? _self.completionDuas : completionDuas // ignore: cast_nullable_to_non_nullable
as List<CompletionDua>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<TasbihCategory>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as TasbihSettings,
  ));
}
/// Create a copy of TasbihData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TasbihSettingsCopyWith<$Res> get settings {
  
  return $TasbihSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [TasbihData].
extension TasbihDataPatterns on TasbihData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasbihData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasbihData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasbihData value)  $default,){
final _that = this;
switch (_that) {
case _TasbihData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasbihData value)?  $default,){
final _that = this;
switch (_that) {
case _TasbihData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'completion_duas')  List<CompletionDua> completionDuas, @JsonKey(name: 'tasbih_categories')  List<TasbihCategory> categories,  TasbihSettings settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasbihData() when $default != null:
return $default(_that.completionDuas,_that.categories,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'completion_duas')  List<CompletionDua> completionDuas, @JsonKey(name: 'tasbih_categories')  List<TasbihCategory> categories,  TasbihSettings settings)  $default,) {final _that = this;
switch (_that) {
case _TasbihData():
return $default(_that.completionDuas,_that.categories,_that.settings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'completion_duas')  List<CompletionDua> completionDuas, @JsonKey(name: 'tasbih_categories')  List<TasbihCategory> categories,  TasbihSettings settings)?  $default,) {final _that = this;
switch (_that) {
case _TasbihData() when $default != null:
return $default(_that.completionDuas,_that.categories,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TasbihData implements TasbihData {
  const _TasbihData({@JsonKey(name: 'completion_duas') final  List<CompletionDua> completionDuas = const [], @JsonKey(name: 'tasbih_categories') required final  List<TasbihCategory> categories, required this.settings}): _completionDuas = completionDuas,_categories = categories;
  factory _TasbihData.fromJson(Map<String, dynamic> json) => _$TasbihDataFromJson(json);

 final  List<CompletionDua> _completionDuas;
@override@JsonKey(name: 'completion_duas') List<CompletionDua> get completionDuas {
  if (_completionDuas is EqualUnmodifiableListView) return _completionDuas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completionDuas);
}

 final  List<TasbihCategory> _categories;
@override@JsonKey(name: 'tasbih_categories') List<TasbihCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  TasbihSettings settings;

/// Create a copy of TasbihData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasbihDataCopyWith<_TasbihData> get copyWith => __$TasbihDataCopyWithImpl<_TasbihData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TasbihDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasbihData&&const DeepCollectionEquality().equals(other._completionDuas, _completionDuas)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_completionDuas),const DeepCollectionEquality().hash(_categories),settings);

@override
String toString() {
  return 'TasbihData(completionDuas: $completionDuas, categories: $categories, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$TasbihDataCopyWith<$Res> implements $TasbihDataCopyWith<$Res> {
  factory _$TasbihDataCopyWith(_TasbihData value, $Res Function(_TasbihData) _then) = __$TasbihDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'completion_duas') List<CompletionDua> completionDuas,@JsonKey(name: 'tasbih_categories') List<TasbihCategory> categories, TasbihSettings settings
});


@override $TasbihSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$TasbihDataCopyWithImpl<$Res>
    implements _$TasbihDataCopyWith<$Res> {
  __$TasbihDataCopyWithImpl(this._self, this._then);

  final _TasbihData _self;
  final $Res Function(_TasbihData) _then;

/// Create a copy of TasbihData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completionDuas = null,Object? categories = null,Object? settings = null,}) {
  return _then(_TasbihData(
completionDuas: null == completionDuas ? _self._completionDuas : completionDuas // ignore: cast_nullable_to_non_nullable
as List<CompletionDua>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<TasbihCategory>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as TasbihSettings,
  ));
}

/// Create a copy of TasbihData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TasbihSettingsCopyWith<$Res> get settings {
  
  return $TasbihSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// @nodoc
mixin _$TasbihSettings {

@JsonKey(name: 'default_category') String get defaultCategory;@JsonKey(name: 'haptic_feedback') bool get hapticFeedback;@JsonKey(name: 'sound_effect') bool get soundEffect;@JsonKey(name: 'auto_reset') bool get autoReset;@JsonKey(name: 'show_transliteration') bool get showTransliteration;@JsonKey(name: 'show_translation') bool get showTranslation;@JsonKey(name: 'dark_mode') bool get darkMode;@JsonKey(name: 'keep_screen_on') bool get keepScreenOn;@JsonKey(name: 'stats_tracking') bool get statsTracking;
/// Create a copy of TasbihSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasbihSettingsCopyWith<TasbihSettings> get copyWith => _$TasbihSettingsCopyWithImpl<TasbihSettings>(this as TasbihSettings, _$identity);

  /// Serializes this TasbihSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasbihSettings&&(identical(other.defaultCategory, defaultCategory) || other.defaultCategory == defaultCategory)&&(identical(other.hapticFeedback, hapticFeedback) || other.hapticFeedback == hapticFeedback)&&(identical(other.soundEffect, soundEffect) || other.soundEffect == soundEffect)&&(identical(other.autoReset, autoReset) || other.autoReset == autoReset)&&(identical(other.showTransliteration, showTransliteration) || other.showTransliteration == showTransliteration)&&(identical(other.showTranslation, showTranslation) || other.showTranslation == showTranslation)&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode)&&(identical(other.keepScreenOn, keepScreenOn) || other.keepScreenOn == keepScreenOn)&&(identical(other.statsTracking, statsTracking) || other.statsTracking == statsTracking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultCategory,hapticFeedback,soundEffect,autoReset,showTransliteration,showTranslation,darkMode,keepScreenOn,statsTracking);

@override
String toString() {
  return 'TasbihSettings(defaultCategory: $defaultCategory, hapticFeedback: $hapticFeedback, soundEffect: $soundEffect, autoReset: $autoReset, showTransliteration: $showTransliteration, showTranslation: $showTranslation, darkMode: $darkMode, keepScreenOn: $keepScreenOn, statsTracking: $statsTracking)';
}


}

/// @nodoc
abstract mixin class $TasbihSettingsCopyWith<$Res>  {
  factory $TasbihSettingsCopyWith(TasbihSettings value, $Res Function(TasbihSettings) _then) = _$TasbihSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'default_category') String defaultCategory,@JsonKey(name: 'haptic_feedback') bool hapticFeedback,@JsonKey(name: 'sound_effect') bool soundEffect,@JsonKey(name: 'auto_reset') bool autoReset,@JsonKey(name: 'show_transliteration') bool showTransliteration,@JsonKey(name: 'show_translation') bool showTranslation,@JsonKey(name: 'dark_mode') bool darkMode,@JsonKey(name: 'keep_screen_on') bool keepScreenOn,@JsonKey(name: 'stats_tracking') bool statsTracking
});




}
/// @nodoc
class _$TasbihSettingsCopyWithImpl<$Res>
    implements $TasbihSettingsCopyWith<$Res> {
  _$TasbihSettingsCopyWithImpl(this._self, this._then);

  final TasbihSettings _self;
  final $Res Function(TasbihSettings) _then;

/// Create a copy of TasbihSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultCategory = null,Object? hapticFeedback = null,Object? soundEffect = null,Object? autoReset = null,Object? showTransliteration = null,Object? showTranslation = null,Object? darkMode = null,Object? keepScreenOn = null,Object? statsTracking = null,}) {
  return _then(_self.copyWith(
defaultCategory: null == defaultCategory ? _self.defaultCategory : defaultCategory // ignore: cast_nullable_to_non_nullable
as String,hapticFeedback: null == hapticFeedback ? _self.hapticFeedback : hapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,soundEffect: null == soundEffect ? _self.soundEffect : soundEffect // ignore: cast_nullable_to_non_nullable
as bool,autoReset: null == autoReset ? _self.autoReset : autoReset // ignore: cast_nullable_to_non_nullable
as bool,showTransliteration: null == showTransliteration ? _self.showTransliteration : showTransliteration // ignore: cast_nullable_to_non_nullable
as bool,showTranslation: null == showTranslation ? _self.showTranslation : showTranslation // ignore: cast_nullable_to_non_nullable
as bool,darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,keepScreenOn: null == keepScreenOn ? _self.keepScreenOn : keepScreenOn // ignore: cast_nullable_to_non_nullable
as bool,statsTracking: null == statsTracking ? _self.statsTracking : statsTracking // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TasbihSettings].
extension TasbihSettingsPatterns on TasbihSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasbihSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasbihSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasbihSettings value)  $default,){
final _that = this;
switch (_that) {
case _TasbihSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasbihSettings value)?  $default,){
final _that = this;
switch (_that) {
case _TasbihSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'default_category')  String defaultCategory, @JsonKey(name: 'haptic_feedback')  bool hapticFeedback, @JsonKey(name: 'sound_effect')  bool soundEffect, @JsonKey(name: 'auto_reset')  bool autoReset, @JsonKey(name: 'show_transliteration')  bool showTransliteration, @JsonKey(name: 'show_translation')  bool showTranslation, @JsonKey(name: 'dark_mode')  bool darkMode, @JsonKey(name: 'keep_screen_on')  bool keepScreenOn, @JsonKey(name: 'stats_tracking')  bool statsTracking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasbihSettings() when $default != null:
return $default(_that.defaultCategory,_that.hapticFeedback,_that.soundEffect,_that.autoReset,_that.showTransliteration,_that.showTranslation,_that.darkMode,_that.keepScreenOn,_that.statsTracking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'default_category')  String defaultCategory, @JsonKey(name: 'haptic_feedback')  bool hapticFeedback, @JsonKey(name: 'sound_effect')  bool soundEffect, @JsonKey(name: 'auto_reset')  bool autoReset, @JsonKey(name: 'show_transliteration')  bool showTransliteration, @JsonKey(name: 'show_translation')  bool showTranslation, @JsonKey(name: 'dark_mode')  bool darkMode, @JsonKey(name: 'keep_screen_on')  bool keepScreenOn, @JsonKey(name: 'stats_tracking')  bool statsTracking)  $default,) {final _that = this;
switch (_that) {
case _TasbihSettings():
return $default(_that.defaultCategory,_that.hapticFeedback,_that.soundEffect,_that.autoReset,_that.showTransliteration,_that.showTranslation,_that.darkMode,_that.keepScreenOn,_that.statsTracking);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'default_category')  String defaultCategory, @JsonKey(name: 'haptic_feedback')  bool hapticFeedback, @JsonKey(name: 'sound_effect')  bool soundEffect, @JsonKey(name: 'auto_reset')  bool autoReset, @JsonKey(name: 'show_transliteration')  bool showTransliteration, @JsonKey(name: 'show_translation')  bool showTranslation, @JsonKey(name: 'dark_mode')  bool darkMode, @JsonKey(name: 'keep_screen_on')  bool keepScreenOn, @JsonKey(name: 'stats_tracking')  bool statsTracking)?  $default,) {final _that = this;
switch (_that) {
case _TasbihSettings() when $default != null:
return $default(_that.defaultCategory,_that.hapticFeedback,_that.soundEffect,_that.autoReset,_that.showTransliteration,_that.showTranslation,_that.darkMode,_that.keepScreenOn,_that.statsTracking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TasbihSettings implements TasbihSettings {
  const _TasbihSettings({@JsonKey(name: 'default_category') required this.defaultCategory, @JsonKey(name: 'haptic_feedback') this.hapticFeedback = true, @JsonKey(name: 'sound_effect') this.soundEffect = false, @JsonKey(name: 'auto_reset') this.autoReset = true, @JsonKey(name: 'show_transliteration') this.showTransliteration = true, @JsonKey(name: 'show_translation') this.showTranslation = true, @JsonKey(name: 'dark_mode') this.darkMode = false, @JsonKey(name: 'keep_screen_on') this.keepScreenOn = true, @JsonKey(name: 'stats_tracking') this.statsTracking = true});
  factory _TasbihSettings.fromJson(Map<String, dynamic> json) => _$TasbihSettingsFromJson(json);

@override@JsonKey(name: 'default_category') final  String defaultCategory;
@override@JsonKey(name: 'haptic_feedback') final  bool hapticFeedback;
@override@JsonKey(name: 'sound_effect') final  bool soundEffect;
@override@JsonKey(name: 'auto_reset') final  bool autoReset;
@override@JsonKey(name: 'show_transliteration') final  bool showTransliteration;
@override@JsonKey(name: 'show_translation') final  bool showTranslation;
@override@JsonKey(name: 'dark_mode') final  bool darkMode;
@override@JsonKey(name: 'keep_screen_on') final  bool keepScreenOn;
@override@JsonKey(name: 'stats_tracking') final  bool statsTracking;

/// Create a copy of TasbihSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasbihSettingsCopyWith<_TasbihSettings> get copyWith => __$TasbihSettingsCopyWithImpl<_TasbihSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TasbihSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasbihSettings&&(identical(other.defaultCategory, defaultCategory) || other.defaultCategory == defaultCategory)&&(identical(other.hapticFeedback, hapticFeedback) || other.hapticFeedback == hapticFeedback)&&(identical(other.soundEffect, soundEffect) || other.soundEffect == soundEffect)&&(identical(other.autoReset, autoReset) || other.autoReset == autoReset)&&(identical(other.showTransliteration, showTransliteration) || other.showTransliteration == showTransliteration)&&(identical(other.showTranslation, showTranslation) || other.showTranslation == showTranslation)&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode)&&(identical(other.keepScreenOn, keepScreenOn) || other.keepScreenOn == keepScreenOn)&&(identical(other.statsTracking, statsTracking) || other.statsTracking == statsTracking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultCategory,hapticFeedback,soundEffect,autoReset,showTransliteration,showTranslation,darkMode,keepScreenOn,statsTracking);

@override
String toString() {
  return 'TasbihSettings(defaultCategory: $defaultCategory, hapticFeedback: $hapticFeedback, soundEffect: $soundEffect, autoReset: $autoReset, showTransliteration: $showTransliteration, showTranslation: $showTranslation, darkMode: $darkMode, keepScreenOn: $keepScreenOn, statsTracking: $statsTracking)';
}


}

/// @nodoc
abstract mixin class _$TasbihSettingsCopyWith<$Res> implements $TasbihSettingsCopyWith<$Res> {
  factory _$TasbihSettingsCopyWith(_TasbihSettings value, $Res Function(_TasbihSettings) _then) = __$TasbihSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'default_category') String defaultCategory,@JsonKey(name: 'haptic_feedback') bool hapticFeedback,@JsonKey(name: 'sound_effect') bool soundEffect,@JsonKey(name: 'auto_reset') bool autoReset,@JsonKey(name: 'show_transliteration') bool showTransliteration,@JsonKey(name: 'show_translation') bool showTranslation,@JsonKey(name: 'dark_mode') bool darkMode,@JsonKey(name: 'keep_screen_on') bool keepScreenOn,@JsonKey(name: 'stats_tracking') bool statsTracking
});




}
/// @nodoc
class __$TasbihSettingsCopyWithImpl<$Res>
    implements _$TasbihSettingsCopyWith<$Res> {
  __$TasbihSettingsCopyWithImpl(this._self, this._then);

  final _TasbihSettings _self;
  final $Res Function(_TasbihSettings) _then;

/// Create a copy of TasbihSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultCategory = null,Object? hapticFeedback = null,Object? soundEffect = null,Object? autoReset = null,Object? showTransliteration = null,Object? showTranslation = null,Object? darkMode = null,Object? keepScreenOn = null,Object? statsTracking = null,}) {
  return _then(_TasbihSettings(
defaultCategory: null == defaultCategory ? _self.defaultCategory : defaultCategory // ignore: cast_nullable_to_non_nullable
as String,hapticFeedback: null == hapticFeedback ? _self.hapticFeedback : hapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,soundEffect: null == soundEffect ? _self.soundEffect : soundEffect // ignore: cast_nullable_to_non_nullable
as bool,autoReset: null == autoReset ? _self.autoReset : autoReset // ignore: cast_nullable_to_non_nullable
as bool,showTransliteration: null == showTransliteration ? _self.showTransliteration : showTransliteration // ignore: cast_nullable_to_non_nullable
as bool,showTranslation: null == showTranslation ? _self.showTranslation : showTranslation // ignore: cast_nullable_to_non_nullable
as bool,darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,keepScreenOn: null == keepScreenOn ? _self.keepScreenOn : keepScreenOn // ignore: cast_nullable_to_non_nullable
as bool,statsTracking: null == statsTracking ? _self.statsTracking : statsTracking // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
