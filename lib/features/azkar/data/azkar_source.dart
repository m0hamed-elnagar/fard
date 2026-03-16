import '../domain/azkar_item.dart';

abstract class IAzkarSource {
  Future<List<AzkarItem>> getAllAzkar();
}
