import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

class MockWerdRepository extends Mock implements WerdRepository {}

void main() {
  late UpdateLastRead useCase;
  late MockQuranRepository mockQuranRepository;
  late MockWerdRepository mockWerdRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    mockWerdRepository = MockWerdRepository();
    useCase = UpdateLastRead(mockQuranRepository, mockWerdRepository);

    registerFallbackValue(
      LastReadPosition(
        ayahNumber: AyahNumber.create(
          surahNumber: 1,
          ayahNumberInSurah: 1,
        ).data!,
        updatedAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
    );
  });

  test(
    'UpdateLastRead should NOT change sessionStartAbsolute if it is already set',
    () async {
      // 1. Initial State: User started at Ayah 1 today
      final initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 1,
        readItemsToday: const {1},
        lastReadAbsolute: 1,
        sessionStartAbsolute: 1, // Start point is fixed at 1
        lastUpdated: DateTime.now(),
        streak: 0,
      );

      when(
        () => mockWerdRepository.getProgress(goalId: any(named: 'goalId')),
      ).thenAnswer((_) async => Result.success(initialProgress));
      when(
        () => mockQuranRepository.updateLastReadPosition(any()),
      ).thenAnswer((_) async => Result.success(null));
      when(
        () => mockWerdRepository.updateProgress(any()),
      ).thenAnswer((_) async => Result.success(null));

      // 2. Act: User reads Ayah 5
      final pos5 = LastReadPosition(
        ayahNumber: AyahNumber.create(
          surahNumber: 1,
          ayahNumberInSurah: 5,
        ).data!,
        updatedAt: DateTime.now(),
      );
      await useCase(pos5);

      // 3. Verify: sessionStartAbsolute should STILL be 1
      verify(
        () => mockWerdRepository.updateProgress(
          any(
            that: isA<WerdProgress>()
                .having((p) => p.sessionStartAbsolute, 'sessionStart', 1)
                .having((p) => p.lastReadAbsolute, 'lastRead', 5),
          ),
        ),
      ).called(1);
    },
  );

  test(
    'UpdateLastRead should NOT change sessionStartAbsolute even on a far jump',
    () async {
      // 1. Initial State: Start point is 1, user has read some
      final initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 2,
        readItemsToday: const {1, 2},
        lastReadAbsolute: 2,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 0,
      );

      when(
        () => mockWerdRepository.getProgress(goalId: any(named: 'goalId')),
      ).thenAnswer((_) async => Result.success(initialProgress));
      when(
        () => mockQuranRepository.updateLastReadPosition(any()),
      ).thenAnswer((_) async => Result.success(null));
      when(
        () => mockWerdRepository.updateProgress(any()),
      ).thenAnswer((_) async => Result.success(null));

      // 2. Act: User jumps to Ayah 50
      final pos50 = LastReadPosition(
        ayahNumber: AyahNumber.create(
          surahNumber: 1,
          ayahNumberInSurah: 50,
        ).data!,
        updatedAt: DateTime.now(),
      );
      await useCase(pos50);

      // 3. Verify: sessionStartAbsolute should STILL be 1
      verify(
        () => mockWerdRepository.updateProgress(
          any(
            that: isA<WerdProgress>()
                .having((p) => p.sessionStartAbsolute, 'sessionStart', 1)
                .having((p) => p.lastReadAbsolute, 'lastRead', 50),
          ),
        ),
      ).called(1);
    },
  );

  test(
    'UpdateLastRead should set sessionStartAbsolute if it is null (first read of day)',
    () async {
      // 1. Initial State: New day, no start point yet
      final initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        readItemsToday: const {},
        lastReadAbsolute: 100, // From yesterday
        sessionStartAbsolute: null,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        streak: 0,
      );

      when(
        () => mockWerdRepository.getProgress(goalId: any(named: 'goalId')),
      ).thenAnswer((_) async => Result.success(initialProgress));
      when(
        () => mockQuranRepository.updateLastReadPosition(any()),
      ).thenAnswer((_) async => Result.success(null));
      when(
        () => mockWerdRepository.updateProgress(any()),
      ).thenAnswer((_) async => Result.success(null));

      // 2. Act: User reads Ayah 101
      final pos101 = LastReadPosition(
        ayahNumber: AyahNumber.create(
          surahNumber: 2,
          ayahNumberInSurah: 94,
        ).data!, // Surah 2, Ayah 94 is abs 101
        updatedAt: DateTime.now(),
      );
      await useCase(pos101);

      // 3. Verify: sessionStartAbsolute should be set to 101
      verify(
        () => mockWerdRepository.updateProgress(
          any(
            that: isA<WerdProgress>().having(
              (p) => p.sessionStartAbsolute,
              'sessionStart',
              101,
            ),
          ),
        ),
      ).called(1);
    },
  );
}
