import 'package:fard/core/di/injection.dart';
import 'package:http/http.dart' as http;
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:fard/features/audio/data/repositories/audio_player_service_impl.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/domain/usecases/play_audio.dart';

Future<void> initAudioFeature() async {
  // Blocs
  getIt.registerLazySingleton(() => AudioBloc(
    audioRepository: getIt(),
    playerService: getIt(),
  ));

  // Use cases
  getIt.registerLazySingleton(() => PlayAudio(
    audioRepository: getIt(),
    playerService: getIt(),
  ));

  // Services
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerServiceImpl());

  // Repository
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl(
    client: getIt(),
  ));

  // External (if not already registered)
  if (!getIt.isRegistered<http.Client>()) {
    getIt.registerLazySingleton(() => http.Client());
  }
}
