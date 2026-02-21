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
}
