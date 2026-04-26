import 'dart:convert';
import 'package:fard/features/tasbih/domain/tasbih_models.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TasbihRepository)
class TasbihRepositoryImpl implements TasbihRepository {
  final Box<int> _progressBox;
  final Box<int> _historyBox;
  final Box<String> _preferredDuaBox;
  final SharedPreferences _prefs;

  TasbihRepositoryImpl(
    @Named('tasbihProgressBox') this._progressBox,
    @Named('tasbihHistoryBox') this._historyBox,
    @Named('tasbihPreferredDuaBox') this._preferredDuaBox,
    this._prefs,
  );

  @override
  Future<TasbihData> getTasbihData() async {
    final String response = await rootBundle.loadString(
      'assets/tasbih_data.json',
    );
    final data = await json.decode(response);
    return TasbihData.fromJson(data);
  }

  @override
  Future<void> saveSettings(TasbihSettings settings) async {
    await _prefs.setString('tasbih_settings', json.encode(settings.toJson()));
  }

  @override
  Future<int> getSessionProgress(String categoryId) async {
    return _progressBox.get(categoryId, defaultValue: 0) ?? 0;
  }

  @override
  Future<void> saveSessionProgress(String categoryId, int progress) async {
    await _progressBox.put(categoryId, progress);
  }

  @override
  Future<void> incrementHistory(String dhikrId) async {
    final current = _historyBox.get(dhikrId, defaultValue: 0) ?? 0;
    await _historyBox.put(dhikrId, current + 1);
  }

  @override
  Future<Map<String, int>> getHistory() async {
    final Map<String, int> history = {};
    for (var key in _historyBox.keys) {
      history[key.toString()] = _historyBox.get(key) ?? 0;
    }
    return history;
  }

  @override
  Future<String?> getPreferredCompletionDuaId(String categoryId) async {
    return _preferredDuaBox.get(categoryId);
  }

  @override
  Future<void> savePreferredCompletionDuaId(
    String categoryId,
    String duaId,
  ) async {
    await _preferredDuaBox.put(categoryId, duaId);
  }

  // ==================== BACKUP / RESTORE ====================

  @override
  Future<Map<String, int>> getAllProgress() async {
    final Map<String, int> progress = {};
    for (var key in _progressBox.keys) {
      progress[key.toString()] = _progressBox.get(key) ?? 0;
    }
    return progress;
  }

  @override
  Future<Map<String, String>> getAllPreferredDuas() async {
    final Map<String, String> preferredDuas = {};
    for (var key in _preferredDuaBox.keys) {
      preferredDuas[key.toString()] = _preferredDuaBox.get(key) ?? '';
    }
    return preferredDuas;
  }

  @override
  Future<void> importData({
    required Map<String, int> progress,
    required Map<String, int> history,
    required Map<String, String> preferredDuas,
  }) async {
    // Clear current data
    await _progressBox.clear();
    await _historyBox.clear();
    await _preferredDuaBox.clear();

    // Import progress
    for (var entry in progress.entries) {
      await _progressBox.put(entry.key, entry.value);
    }

    // Import history
    for (var entry in history.entries) {
      await _historyBox.put(entry.key, entry.value);
    }

    // Import preferred duas
    for (var entry in preferredDuas.entries) {
      await _preferredDuaBox.put(entry.key, entry.value);
    }

    await _progressBox.flush();
    await _historyBox.flush();
    await _preferredDuaBox.flush();
  }
}
