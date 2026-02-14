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
  const factory AzkarEvent.resetCategory(String category) = _ResetCategory;
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

    on<_IncrementCount>((event, emit) async {
      final currentState = state;
      if (currentState is _AzkarLoaded) {
        final newList = List<AzkarItem>.from(currentState.azkar);
        final item = newList[event.index];
        if (item.currentCount < item.count) {
          final updatedItem = item.copyWith(currentCount: item.currentCount + 1);
          newList[event.index] = updatedItem;
          
          // Save to repository (persistence)
          await _repository.saveProgress(updatedItem);
          
          emit(AzkarState.azkarLoaded(currentState.category, newList));
        }
      }
    });

    on<_ResetCategory>((event, emit) async {
      try {
        await _repository.resetCategory(event.category);
        final azkar = await _repository.getAzkarByCategory(event.category);
        emit(AzkarState.azkarLoaded(event.category, azkar));
      } catch (e) {
        emit(AzkarState.error(e.toString()));
      }
    });
  }
}
