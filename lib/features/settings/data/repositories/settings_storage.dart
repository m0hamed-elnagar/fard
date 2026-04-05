import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Safe persistence wrapper for SharedPreferences.
///
/// Provides error handling with `try/catch` + `debugPrint` on failure,
/// and handles JSON encode/decode with safe fallbacks.
@LazySingleton()
class SettingsStorage {
  final SharedPreferences _prefs;

  SettingsStorage(this._prefs);

  // ==================== String ====================

  String? readString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<bool> writeString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      debugPrint('SettingsStorage: Failed to write string [$key]: $e');
      return false;
    }
  }

  // ==================== Bool ====================

  bool readBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<bool> writeBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      debugPrint('SettingsStorage: Failed to write bool [$key]: $e');
      return false;
    }
  }

  // ==================== Int ====================

  int readInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<bool> writeInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      debugPrint('SettingsStorage: Failed to write int [$key]: $e');
      return false;
    }
  }

  // ==================== Double (stored as String) ====================

  double? readDouble(String key) {
    final val = _prefs.get(key);
    if (val == null) return null;
    return double.tryParse(val.toString());
  }

  Future<bool> writeDouble(String key, double value) async {
    try {
      return await _prefs.setString(key, value.toString());
    } catch (e) {
      debugPrint('SettingsStorage: Failed to write double [$key]: $e');
      return false;
    }
  }

  // ==================== JSON List ====================

  List<T> readJsonList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final String? jsonStr = _prefs.getString(key);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.whereType<Map<String, dynamic>>().map(fromJson).toList();
    } catch (e) {
      debugPrint('SettingsStorage: Failed to read json list [$key]: $e');
      return [];
    }
  }

  Future<bool> writeJsonList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final String jsonStr = jsonEncode(items.map(toJson).toList());
      return await _prefs.setString(key, jsonStr);
    } catch (e) {
      debugPrint('SettingsStorage: Failed to write json list [$key]: $e');
      return false;
    }
  }

  // ==================== Raw Access (for edge cases) ====================

  SharedPreferences get prefs => _prefs;
}
