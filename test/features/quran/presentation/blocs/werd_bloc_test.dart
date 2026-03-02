import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/domain/entities/werd_progress.dart';
import 'package:fard/features/quran/domain/repositories/werd_repository.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/presentation/blocs/werd_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWerdRepository extends Mock implements WerdRepository {}

void main() {
  late MockWerdRepository mockWerdRepository;
  late WerdBloc werdBloc;

  final tGoal = WerdGoal(
    type: WerdGoalType.fixedAmount,
    value: 10,
    unit: WerdUnit.ayah,
    startDate: DateTime(2026, 3, 2),
  );

  final tProgress = WerdProgress(
    totalAyahsReadToday: 5,
    lastReadAyah: AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data,
    lastReadAbsolute: 1,
    lastUpdated: DateTime(2026, 3, 2),
    streak: 2,
  );

  setUpAll(() {
    registerFallbackValue(tGoal);
    registerFallbackValue(tProgress);
    registerFallbackValue(AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 1).data!);
  });

  setUp(() {
    mockWerdRepository = MockWerdRepository();
    when(() => mockWerdRepository.watchProgress())
        .thenAnswer((_) => const Stream.empty());
    werdBloc = WerdBloc(mockWerdRepository);
  });

  tearDown(() {
    werdBloc.close();
  });

  blocTest<WerdBloc, WerdState>(
    'should increment progress by delta when trackAyahRead is added',
    build: () {
      when(() => mockWerdRepository.getProgress())
          .thenAnswer((_) async => Result.success(tProgress));
      when(() => mockWerdRepository.updateProgress(any()))
          .thenAnswer((_) async => Result.success(null));
      return werdBloc;
    },
    seed: () => WerdState(goal: tGoal, progress: tProgress),
    act: (bloc) => bloc.add(WerdEvent.trackAyahRead(
      AyahNumber.create(surahNumber: 1, ayahNumberInSurah: 10).data!,
    )),
    verify: (_) {
      // 1:1 absolute is 1. 1:10 absolute is 10. Delta is 9.
      // New total should be 5 + 9 = 14.
      verify(() => mockWerdRepository.updateProgress(any(
        that: isA<WerdProgress>().having((p) => p.totalAyahsReadToday, 'total', 14),
      ))).called(1);
    },
  );
}
