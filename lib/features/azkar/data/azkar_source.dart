import '../domain/azkar_item.dart';

abstract class IAzkarSource {
  Future<List<AzkarItem>> getAllAzkar();
  Future<void> saveProgress(AzkarItem item);
  Future<void> resetCategory(String category);
  Future<void> resetAll();
  Future<List<String>> getCategories();
  Future<List<AzkarItem>> getAzkarByCategory(String category);
}
