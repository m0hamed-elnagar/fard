import 'package:fard/features/tasbih/domain/tasbih_models.dart';

abstract class TasbihRepository {
  Future<TasbihData> getTasbihData();
  Future<void> saveSettings(TasbihSettings settings);
  Future<int> getSessionProgress(String categoryId);
  Future<void> saveSessionProgress(String categoryId, int progress);
  Future<void> incrementHistory(String dhikrId);
  Future<Map<String, int>> getHistory();
  Future<String?> getPreferredCompletionDuaId(String categoryId);
  Future<void> savePreferredCompletionDuaId(String categoryId, String duaId);

  // ==================== BACKUP / RESTORE ====================

  /// Get all tasbih progress
  Future<Map<String, int>> getAllProgress();

  /// Get all preferred completion duas
  Future<Map<String, String>> getAllPreferredDuas();

  /// Import tasbih data
  Future<void> importData({
    required Map<String, int> progress,
    required Map<String, int> history,
    required Map<String, String> preferredDuas,
  });
}
