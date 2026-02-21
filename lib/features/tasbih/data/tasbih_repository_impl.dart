import 'dart:convert';
import 'package:fard/features/tasbih/domain/tasbih_models.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihRepositoryImpl implements TasbihRepository {
  final Box<int> _progressBox;
  final Box<int> _historyBox;
  final Box<String> _preferredDuaBox;
  final SharedPreferences _prefs;

  TasbihRepositoryImpl(
    this._progressBox, 
    this._historyBox, 
    this._preferredDuaBox,
    this._prefs
  );

  @override
  Future<TasbihData> getTasbihData() async {
    final String response = await rootBundle.loadString('assets/tasbih_data.json');
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
  Future<void> savePreferredCompletionDuaId(String categoryId, String duaId) async {
    await _preferredDuaBox.put(categoryId, duaId);
  }
}
