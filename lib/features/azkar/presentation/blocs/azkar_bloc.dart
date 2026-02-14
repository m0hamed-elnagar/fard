import 'dart:async';
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
  const factory AzkarEvent.resetItem(int index) = _ResetItem;
  const factory AzkarEvent.resetAll() = _ResetAll;
}

@freezed
class AzkarState with _$AzkarState {
  const factory AzkarState({
    @Default(false) bool isLoading,
    @Default([]) List<String> categories,
    @Default([]) List<AzkarItem> azkar,
    String? currentCategory,
    String? error,
  }) = _AzkarState;

  factory AzkarState.initial() => const AzkarState();
}

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final AzkarRepository _repository;

  AzkarBloc(this._repository) : super(AzkarState.initial()) {
    on<_LoadCategories>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final categories = await _repository.getCategories()
            .timeout(const Duration(seconds: 15));
        emit(state.copyWith(isLoading: false, categories: categories));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false, 
          error: e is TimeoutException ? 'Request timed out' : e.toString()
        ));
      }
    });

    on<_LoadAzkar>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final azkar = await _repository.getAzkarByCategory(event.category)
            .timeout(const Duration(seconds: 15));
        emit(state.copyWith(
          isLoading: false, 
          azkar: azkar, 
          currentCategory: event.category
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false, 
          error: e is TimeoutException ? 'Request timed out' : e.toString()
        ));
      }
    });

    on<_IncrementCount>((event, emit) async {
      final newList = List<AzkarItem>.from(state.azkar);
      final item = newList[event.index];
      if (item.currentCount < item.count) {
        final updatedItem = item.copyWith(currentCount: item.currentCount + 1);
        newList[event.index] = updatedItem;
        
        // Save to repository (persistence)
        await _repository.saveProgress(updatedItem);
        
        emit(state.copyWith(azkar: newList));
      }
    });

    on<_ResetCategory>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        await _repository.resetCategory(event.category);
        final azkar = await _repository.getAzkarByCategory(event.category)
            .timeout(const Duration(seconds: 15));
        emit(state.copyWith(isLoading: false, azkar: azkar));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<_ResetItem>((event, emit) async {
      final newList = List<AzkarItem>.from(state.azkar);
      final item = newList[event.index];
      final updatedItem = item.copyWith(currentCount: 0);
      newList[event.index] = updatedItem;
      
      await _repository.saveProgress(updatedItem);
      emit(state.copyWith(azkar: newList));
    });

    on<_ResetAll>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        await _repository.resetAll();
        // Clear everything and reload categories to show fresh counts (all 0)
        emit(state.copyWith(
          isLoading: false, 
          categories: [], 
          azkar: [], 
          currentCategory: null
        ));
        add(const AzkarEvent.loadCategories());
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}
