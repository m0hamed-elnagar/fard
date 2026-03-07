import 'package:fard/core/di/injection.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/data/repositories/werd_repository_impl.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';

Future<void> initWerdFeature() async {
  // Repository
  getIt.registerLazySingleton<WerdRepository>(() => WerdRepositoryImpl(getIt()));

  // Blocs
  getIt.registerLazySingleton(() => WerdBloc(getIt()));
}
