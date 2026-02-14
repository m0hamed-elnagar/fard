import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/azkar_repository.dart';
import '../../domain/azkar_item.dart';

part 'azkar_bloc.freezed.dart';

@freezed
class AzkarEvent with _$AzkarEvent {
  const factory AzkarEvent.loadCategories() = _LoadCategories;
  const factory AzkarEvent.loadAzkar(String category) = _LoadAzkar;
  const factory AzkarEvent.incrementCount(int index) = _IncrementCount;
}

@freezed
class AzkarState with _$AzkarState {
  const factory AzkarState.initial() = _Initial;
  const factory AzkarState.loading() = _Loading;
  const factory AzkarState.categoriesLoaded(List<String> categories) = _CategoriesLoaded;
  const factory AzkarState.azkarLoaded(String category, List<AzkarItem> azkar) = _AzkarLoaded;
  const factory AzkarState.error(String message) = _Error;
}

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final AzkarRepository _repository;

  AzkarBloc(this._repository) : super(const AzkarState.initial()) {
    on<_LoadCategories>((event, emit) async {
      emit(const AzkarState.loading());
      try {
        final categories = await _repository.getCategories();
        emit(AzkarState.categoriesLoaded(categories));
      } catch (e) {
        emit(AzkarState.error(e.toString()));
      }
    });

    on<_LoadAzkar>((event, emit) async {
      emit(const AzkarState.loading());
      try {
        final azkar = await _repository.getAzkarByCategory(event.category);
        emit(AzkarState.azkarLoaded(event.category, azkar));
      } catch (e) {
        emit(AzkarState.error(e.toString()));
      }
    });

    on<_IncrementCount>((event, emit) {
      state.maybeWhen(
        azkarLoaded: (category, azkar) {
          final newList = List<AzkarItem>.from(azkar);
          final item = newList[event.index];
          if (item.currentCount < item.count) {
            newList[event.index] = item.copyWith(currentCount: item.currentCount + 1);
            emit(AzkarState.azkarLoaded(category, newList));
          }
        },
        orElse: () {},
      );
    });
  }
}
