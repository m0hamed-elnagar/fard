// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'azkar_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AzkarEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadCategories,
    required TResult Function(String category) loadAzkar,
    required TResult Function(int index) incrementCount,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadCategories,
    TResult? Function(String category)? loadAzkar,
    TResult? Function(int index)? incrementCount,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadCategories,
    TResult Function(String category)? loadAzkar,
    TResult Function(int index)? incrementCount,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadCategories value) loadCategories,
    required TResult Function(_LoadAzkar value) loadAzkar,
    required TResult Function(_IncrementCount value) incrementCount,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadCategories value)? loadCategories,
    TResult? Function(_LoadAzkar value)? loadAzkar,
    TResult? Function(_IncrementCount value)? incrementCount,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadCategories value)? loadCategories,
    TResult Function(_LoadAzkar value)? loadAzkar,
    TResult Function(_IncrementCount value)? incrementCount,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AzkarEventCopyWith<$Res> {
  factory $AzkarEventCopyWith(
          AzkarEvent value, $Res Function(AzkarEvent) then) =
      _$AzkarEventCopyWithImpl<$Res, AzkarEvent>;
}

/// @nodoc
class _$AzkarEventCopyWithImpl<$Res, $Val extends AzkarEvent>
    implements $AzkarEventCopyWith<$Res> {
  _$AzkarEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LoadCategoriesImplCopyWith<$Res> {
  factory _$$LoadCategoriesImplCopyWith(_$LoadCategoriesImpl value,
          $Res Function(_$LoadCategoriesImpl) then) =
      __$$LoadCategoriesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadCategoriesImplCopyWithImpl<$Res>
    extends _$AzkarEventCopyWithImpl<$Res, _$LoadCategoriesImpl>
    implements _$$LoadCategoriesImplCopyWith<$Res> {
  __$$LoadCategoriesImplCopyWithImpl(
      _$LoadCategoriesImpl _value, $Res Function(_$LoadCategoriesImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadCategoriesImpl implements _LoadCategories {
  const _$LoadCategoriesImpl();

  @override
  String toString() {
    return 'AzkarEvent.loadCategories()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadCategoriesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadCategories,
    required TResult Function(String category) loadAzkar,
    required TResult Function(int index) incrementCount,
  }) {
    return loadCategories();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadCategories,
    TResult? Function(String category)? loadAzkar,
    TResult? Function(int index)? incrementCount,
  }) {
    return loadCategories?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadCategories,
    TResult Function(String category)? loadAzkar,
    TResult Function(int index)? incrementCount,
    required TResult orElse(),
  }) {
    if (loadCategories != null) {
      return loadCategories();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadCategories value) loadCategories,
    required TResult Function(_LoadAzkar value) loadAzkar,
    required TResult Function(_IncrementCount value) incrementCount,
  }) {
    return loadCategories(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadCategories value)? loadCategories,
    TResult? Function(_LoadAzkar value)? loadAzkar,
    TResult? Function(_IncrementCount value)? incrementCount,
  }) {
    return loadCategories?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadCategories value)? loadCategories,
    TResult Function(_LoadAzkar value)? loadAzkar,
    TResult Function(_IncrementCount value)? incrementCount,
    required TResult orElse(),
  }) {
    if (loadCategories != null) {
      return loadCategories(this);
    }
    return orElse();
  }
}

abstract class _LoadCategories implements AzkarEvent {
  const factory _LoadCategories() = _$LoadCategoriesImpl;
}

/// @nodoc
abstract class _$$LoadAzkarImplCopyWith<$Res> {
  factory _$$LoadAzkarImplCopyWith(
          _$LoadAzkarImpl value, $Res Function(_$LoadAzkarImpl) then) =
      __$$LoadAzkarImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String category});
}

/// @nodoc
class __$$LoadAzkarImplCopyWithImpl<$Res>
    extends _$AzkarEventCopyWithImpl<$Res, _$LoadAzkarImpl>
    implements _$$LoadAzkarImplCopyWith<$Res> {
  __$$LoadAzkarImplCopyWithImpl(
      _$LoadAzkarImpl _value, $Res Function(_$LoadAzkarImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
  }) {
    return _then(_$LoadAzkarImpl(
      null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoadAzkarImpl implements _LoadAzkar {
  const _$LoadAzkarImpl(this.category);

  @override
  final String category;

  @override
  String toString() {
    return 'AzkarEvent.loadAzkar(category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadAzkarImpl &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadAzkarImplCopyWith<_$LoadAzkarImpl> get copyWith =>
      __$$LoadAzkarImplCopyWithImpl<_$LoadAzkarImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadCategories,
    required TResult Function(String category) loadAzkar,
    required TResult Function(int index) incrementCount,
  }) {
    return loadAzkar(category);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadCategories,
    TResult? Function(String category)? loadAzkar,
    TResult? Function(int index)? incrementCount,
  }) {
    return loadAzkar?.call(category);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadCategories,
    TResult Function(String category)? loadAzkar,
    TResult Function(int index)? incrementCount,
    required TResult orElse(),
  }) {
    if (loadAzkar != null) {
      return loadAzkar(category);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadCategories value) loadCategories,
    required TResult Function(_LoadAzkar value) loadAzkar,
    required TResult Function(_IncrementCount value) incrementCount,
  }) {
    return loadAzkar(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadCategories value)? loadCategories,
    TResult? Function(_LoadAzkar value)? loadAzkar,
    TResult? Function(_IncrementCount value)? incrementCount,
  }) {
    return loadAzkar?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadCategories value)? loadCategories,
    TResult Function(_LoadAzkar value)? loadAzkar,
    TResult Function(_IncrementCount value)? incrementCount,
    required TResult orElse(),
  }) {
    if (loadAzkar != null) {
      return loadAzkar(this);
    }
    return orElse();
  }
}

abstract class _LoadAzkar implements AzkarEvent {
  const factory _LoadAzkar(final String category) = _$LoadAzkarImpl;

  String get category;
  @JsonKey(ignore: true)
  _$$LoadAzkarImplCopyWith<_$LoadAzkarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IncrementCountImplCopyWith<$Res> {
  factory _$$IncrementCountImplCopyWith(_$IncrementCountImpl value,
          $Res Function(_$IncrementCountImpl) then) =
      __$$IncrementCountImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int index});
}

/// @nodoc
class __$$IncrementCountImplCopyWithImpl<$Res>
    extends _$AzkarEventCopyWithImpl<$Res, _$IncrementCountImpl>
    implements _$$IncrementCountImplCopyWith<$Res> {
  __$$IncrementCountImplCopyWithImpl(
      _$IncrementCountImpl _value, $Res Function(_$IncrementCountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
  }) {
    return _then(_$IncrementCountImpl(
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$IncrementCountImpl implements _IncrementCount {
  const _$IncrementCountImpl(this.index);

  @override
  final int index;

  @override
  String toString() {
    return 'AzkarEvent.incrementCount(index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncrementCountImpl &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, index);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncrementCountImplCopyWith<_$IncrementCountImpl> get copyWith =>
      __$$IncrementCountImplCopyWithImpl<_$IncrementCountImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadCategories,
    required TResult Function(String category) loadAzkar,
    required TResult Function(int index) incrementCount,
  }) {
    return incrementCount(index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadCategories,
    TResult? Function(String category)? loadAzkar,
    TResult? Function(int index)? incrementCount,
  }) {
    return incrementCount?.call(index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadCategories,
    TResult Function(String category)? loadAzkar,
    TResult Function(int index)? incrementCount,
    required TResult orElse(),
  }) {
    if (incrementCount != null) {
      return incrementCount(index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadCategories value) loadCategories,
    required TResult Function(_LoadAzkar value) loadAzkar,
    required TResult Function(_IncrementCount value) incrementCount,
  }) {
    return incrementCount(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadCategories value)? loadCategories,
    TResult? Function(_LoadAzkar value)? loadAzkar,
    TResult? Function(_IncrementCount value)? incrementCount,
  }) {
    return incrementCount?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadCategories value)? loadCategories,
    TResult Function(_LoadAzkar value)? loadAzkar,
    TResult Function(_IncrementCount value)? incrementCount,
    required TResult orElse(),
  }) {
    if (incrementCount != null) {
      return incrementCount(this);
    }
    return orElse();
  }
}

abstract class _IncrementCount implements AzkarEvent {
  const factory _IncrementCount(final int index) = _$IncrementCountImpl;

  int get index;
  @JsonKey(ignore: true)
  _$$IncrementCountImplCopyWith<_$IncrementCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AzkarState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<String> categories) categoriesLoaded,
    required TResult Function(String category, List<AzkarItem> azkar)
        azkarLoaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<String> categories)? categoriesLoaded,
    TResult? Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<String> categories)? categoriesLoaded,
    TResult Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_CategoriesLoaded value) categoriesLoaded,
    required TResult Function(_AzkarLoaded value) azkarLoaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult? Function(_AzkarLoaded value)? azkarLoaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult Function(_AzkarLoaded value)? azkarLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AzkarStateCopyWith<$Res> {
  factory $AzkarStateCopyWith(
          AzkarState value, $Res Function(AzkarState) then) =
      _$AzkarStateCopyWithImpl<$Res, AzkarState>;
}

/// @nodoc
class _$AzkarStateCopyWithImpl<$Res, $Val extends AzkarState>
    implements $AzkarStateCopyWith<$Res> {
  _$AzkarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AzkarStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AzkarState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<String> categories) categoriesLoaded,
    required TResult Function(String category, List<AzkarItem> azkar)
        azkarLoaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<String> categories)? categoriesLoaded,
    TResult? Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<String> categories)? categoriesLoaded,
    TResult Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_CategoriesLoaded value) categoriesLoaded,
    required TResult Function(_AzkarLoaded value) azkarLoaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult? Function(_AzkarLoaded value)? azkarLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult Function(_AzkarLoaded value)? azkarLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AzkarState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$AzkarStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AzkarState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<String> categories) categoriesLoaded,
    required TResult Function(String category, List<AzkarItem> azkar)
        azkarLoaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<String> categories)? categoriesLoaded,
    TResult? Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<String> categories)? categoriesLoaded,
    TResult Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_CategoriesLoaded value) categoriesLoaded,
    required TResult Function(_AzkarLoaded value) azkarLoaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult? Function(_AzkarLoaded value)? azkarLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult Function(_AzkarLoaded value)? azkarLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AzkarState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$CategoriesLoadedImplCopyWith<$Res> {
  factory _$$CategoriesLoadedImplCopyWith(_$CategoriesLoadedImpl value,
          $Res Function(_$CategoriesLoadedImpl) then) =
      __$$CategoriesLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<String> categories});
}

/// @nodoc
class __$$CategoriesLoadedImplCopyWithImpl<$Res>
    extends _$AzkarStateCopyWithImpl<$Res, _$CategoriesLoadedImpl>
    implements _$$CategoriesLoadedImplCopyWith<$Res> {
  __$$CategoriesLoadedImplCopyWithImpl(_$CategoriesLoadedImpl _value,
      $Res Function(_$CategoriesLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
  }) {
    return _then(_$CategoriesLoadedImpl(
      null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$CategoriesLoadedImpl implements _CategoriesLoaded {
  const _$CategoriesLoadedImpl(final List<String> categories)
      : _categories = categories;

  final List<String> _categories;
  @override
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'AzkarState.categoriesLoaded(categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoriesLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_categories));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoriesLoadedImplCopyWith<_$CategoriesLoadedImpl> get copyWith =>
      __$$CategoriesLoadedImplCopyWithImpl<_$CategoriesLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<String> categories) categoriesLoaded,
    required TResult Function(String category, List<AzkarItem> azkar)
        azkarLoaded,
    required TResult Function(String message) error,
  }) {
    return categoriesLoaded(categories);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<String> categories)? categoriesLoaded,
    TResult? Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult? Function(String message)? error,
  }) {
    return categoriesLoaded?.call(categories);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<String> categories)? categoriesLoaded,
    TResult Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (categoriesLoaded != null) {
      return categoriesLoaded(categories);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_CategoriesLoaded value) categoriesLoaded,
    required TResult Function(_AzkarLoaded value) azkarLoaded,
    required TResult Function(_Error value) error,
  }) {
    return categoriesLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult? Function(_AzkarLoaded value)? azkarLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return categoriesLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult Function(_AzkarLoaded value)? azkarLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (categoriesLoaded != null) {
      return categoriesLoaded(this);
    }
    return orElse();
  }
}

abstract class _CategoriesLoaded implements AzkarState {
  const factory _CategoriesLoaded(final List<String> categories) =
      _$CategoriesLoadedImpl;

  List<String> get categories;
  @JsonKey(ignore: true)
  _$$CategoriesLoadedImplCopyWith<_$CategoriesLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AzkarLoadedImplCopyWith<$Res> {
  factory _$$AzkarLoadedImplCopyWith(
          _$AzkarLoadedImpl value, $Res Function(_$AzkarLoadedImpl) then) =
      __$$AzkarLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String category, List<AzkarItem> azkar});
}

/// @nodoc
class __$$AzkarLoadedImplCopyWithImpl<$Res>
    extends _$AzkarStateCopyWithImpl<$Res, _$AzkarLoadedImpl>
    implements _$$AzkarLoadedImplCopyWith<$Res> {
  __$$AzkarLoadedImplCopyWithImpl(
      _$AzkarLoadedImpl _value, $Res Function(_$AzkarLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? azkar = null,
  }) {
    return _then(_$AzkarLoadedImpl(
      null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      null == azkar
          ? _value._azkar
          : azkar // ignore: cast_nullable_to_non_nullable
              as List<AzkarItem>,
    ));
  }
}

/// @nodoc

class _$AzkarLoadedImpl implements _AzkarLoaded {
  const _$AzkarLoadedImpl(this.category, final List<AzkarItem> azkar)
      : _azkar = azkar;

  @override
  final String category;
  final List<AzkarItem> _azkar;
  @override
  List<AzkarItem> get azkar {
    if (_azkar is EqualUnmodifiableListView) return _azkar;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_azkar);
  }

  @override
  String toString() {
    return 'AzkarState.azkarLoaded(category: $category, azkar: $azkar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AzkarLoadedImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._azkar, _azkar));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, category, const DeepCollectionEquality().hash(_azkar));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AzkarLoadedImplCopyWith<_$AzkarLoadedImpl> get copyWith =>
      __$$AzkarLoadedImplCopyWithImpl<_$AzkarLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<String> categories) categoriesLoaded,
    required TResult Function(String category, List<AzkarItem> azkar)
        azkarLoaded,
    required TResult Function(String message) error,
  }) {
    return azkarLoaded(category, azkar);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<String> categories)? categoriesLoaded,
    TResult? Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult? Function(String message)? error,
  }) {
    return azkarLoaded?.call(category, azkar);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<String> categories)? categoriesLoaded,
    TResult Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (azkarLoaded != null) {
      return azkarLoaded(category, azkar);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_CategoriesLoaded value) categoriesLoaded,
    required TResult Function(_AzkarLoaded value) azkarLoaded,
    required TResult Function(_Error value) error,
  }) {
    return azkarLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult? Function(_AzkarLoaded value)? azkarLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return azkarLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult Function(_AzkarLoaded value)? azkarLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (azkarLoaded != null) {
      return azkarLoaded(this);
    }
    return orElse();
  }
}

abstract class _AzkarLoaded implements AzkarState {
  const factory _AzkarLoaded(
      final String category, final List<AzkarItem> azkar) = _$AzkarLoadedImpl;

  String get category;
  List<AzkarItem> get azkar;
  @JsonKey(ignore: true)
  _$$AzkarLoadedImplCopyWith<_$AzkarLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$AzkarStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AzkarState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<String> categories) categoriesLoaded,
    required TResult Function(String category, List<AzkarItem> azkar)
        azkarLoaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<String> categories)? categoriesLoaded,
    TResult? Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<String> categories)? categoriesLoaded,
    TResult Function(String category, List<AzkarItem> azkar)? azkarLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_CategoriesLoaded value) categoriesLoaded,
    required TResult Function(_AzkarLoaded value) azkarLoaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult? Function(_AzkarLoaded value)? azkarLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_CategoriesLoaded value)? categoriesLoaded,
    TResult Function(_AzkarLoaded value)? azkarLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements AzkarState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
