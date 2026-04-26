import '../domain/azkar_item.dart';

abstract class IAzkarSource {
  Future<List<AzkarItem>> getAllAzkar();
  Future<void> saveProgress(AzkarItem item);
  Future<void> resetCategory(String category);
  Future<void> resetAll();
  Future<List<String>> getCategories();
  Future<List<AzkarItem>> getAzkarByCategory(String category);

  // ==================== BACKUP / RESTORE ====================

  /// Get all progress as a map
  Future<Map<String, int>> getAllProgress();

  /// Import progress from a map
  Future<void> importProgress(Map<String, int> progress);
}
