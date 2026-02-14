// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'azkar_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AzkarItem {
  String get category => throw _privateConstructorUsedError;
  String get zekr => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  int get currentCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AzkarItemCopyWith<AzkarItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AzkarItemCopyWith<$Res> {
  factory $AzkarItemCopyWith(AzkarItem value, $Res Function(AzkarItem) then) =
      _$AzkarItemCopyWithImpl<$Res, AzkarItem>;
  @useResult
  $Res call(
      {String category,
      String zekr,
      String description,
      int count,
      String reference,
      int currentCount});
}

/// @nodoc
class _$AzkarItemCopyWithImpl<$Res, $Val extends AzkarItem>
    implements $AzkarItemCopyWith<$Res> {
  _$AzkarItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? zekr = null,
    Object? description = null,
    Object? count = null,
    Object? reference = null,
    Object? currentCount = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      zekr: null == zekr
          ? _value.zekr
          : zekr // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      currentCount: null == currentCount
          ? _value.currentCount
          : currentCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AzkarItemImplCopyWith<$Res>
    implements $AzkarItemCopyWith<$Res> {
  factory _$$AzkarItemImplCopyWith(
          _$AzkarItemImpl value, $Res Function(_$AzkarItemImpl) then) =
      __$$AzkarItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category,
      String zekr,
      String description,
      int count,
      String reference,
      int currentCount});
}

/// @nodoc
class __$$AzkarItemImplCopyWithImpl<$Res>
    extends _$AzkarItemCopyWithImpl<$Res, _$AzkarItemImpl>
    implements _$$AzkarItemImplCopyWith<$Res> {
  __$$AzkarItemImplCopyWithImpl(
      _$AzkarItemImpl _value, $Res Function(_$AzkarItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? zekr = null,
    Object? description = null,
    Object? count = null,
    Object? reference = null,
    Object? currentCount = null,
  }) {
    return _then(_$AzkarItemImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      zekr: null == zekr
          ? _value.zekr
          : zekr // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      currentCount: null == currentCount
          ? _value.currentCount
          : currentCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AzkarItemImpl implements _AzkarItem {
  const _$AzkarItemImpl(
      {required this.category,
      required this.zekr,
      required this.description,
      required this.count,
      required this.reference,
      this.currentCount = 0});

  @override
  final String category;
  @override
  final String zekr;
  @override
  final String description;
  @override
  final int count;
  @override
  final String reference;
  @override
  @JsonKey()
  final int currentCount;

  @override
  String toString() {
    return 'AzkarItem(category: $category, zekr: $zekr, description: $description, count: $count, reference: $reference, currentCount: $currentCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AzkarItemImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.zekr, zekr) || other.zekr == zekr) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.currentCount, currentCount) ||
                other.currentCount == currentCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, category, zekr, description, count, reference, currentCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AzkarItemImplCopyWith<_$AzkarItemImpl> get copyWith =>
      __$$AzkarItemImplCopyWithImpl<_$AzkarItemImpl>(this, _$identity);
}

abstract class _AzkarItem implements AzkarItem {
  const factory _AzkarItem(
      {required final String category,
      required final String zekr,
      required final String description,
      required final int count,
      required final String reference,
      final int currentCount}) = _$AzkarItemImpl;

  @override
  String get category;
  @override
  String get zekr;
  @override
  String get description;
  @override
  int get count;
  @override
  String get reference;
  @override
  int get currentCount;
  @override
  @JsonKey(ignore: true)
  _$$AzkarItemImplCopyWith<_$AzkarItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
