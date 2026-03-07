import 'package:fard/core/di/injection.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/data/repositories/werd_repository_impl.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/quran/domain/usecases/watch_bookmark.dart';

Future<void> initWerdFeature() async {
  // Use Cases
  getIt.registerLazySingleton(() => WatchBookmark(getIt()));

  // Repository
  getIt.registerLazySingleton<WerdRepository>(() => WerdRepositoryImpl(getIt()));

  // Blocs
  getIt.registerLazySingleton(() => WerdBloc(getIt(), getIt()));
}
