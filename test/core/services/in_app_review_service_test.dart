import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/services/in_app_review_service.dart';

class MockInAppReview extends Mock implements InAppReview {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late InAppReviewService service;
  late MockInAppReview mockInAppReview;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = InAppReviewService(prefs);
    mockInAppReview = MockInAppReview();
  });

  group('InAppReviewService Tests', () {
    test('does not prompt if streak is less than 7', () async {
      await service.checkAndPromptReviewIfEligible(
        currentStreak: 5,
        customInstallTime: DateTime.now().subtract(const Duration(days: 10)),
        customInAppReview: mockInAppReview,
        isTestEnvironment: true,
      );

      final hasPrompted = prefs.getBool('has_been_prompted_for_review') ?? false;
      expect(hasPrompted, isFalse);
      verifyNever(() => mockInAppReview.requestReview());
    });

    test('does not prompt if install age is less than 7 days even with high streak', () async {
      await service.checkAndPromptReviewIfEligible(
        currentStreak: 10,
        customInstallTime: DateTime.now().subtract(const Duration(days: 2)),
        customInAppReview: mockInAppReview,
        isTestEnvironment: true,
      );

      final hasPrompted = prefs.getBool('has_been_prompted_for_review') ?? false;
      expect(hasPrompted, isFalse);
      verifyNever(() => mockInAppReview.requestReview());
    });

    test('does not prompt if already prompted previously', () async {
      await prefs.setBool('has_been_prompted_for_review', true);

      await service.checkAndPromptReviewIfEligible(
        currentStreak: 10,
        customInstallTime: DateTime.now().subtract(const Duration(days: 10)),
        customInAppReview: mockInAppReview,
        isTestEnvironment: true,
      );

      final hasPrompted = prefs.getBool('has_been_prompted_for_review') ?? false;
      expect(hasPrompted, isTrue);
      verifyNever(() => mockInAppReview.requestReview());
    });

    test('prompts review and persists once-ever flag when BOTH streak >= 7 and install age >= 7 days hold', () async {
      when(() => mockInAppReview.isAvailable()).thenAnswer((_) async => true);
      when(() => mockInAppReview.requestReview()).thenAnswer((_) async => {});

      await service.checkAndPromptReviewIfEligible(
        currentStreak: 7,
        customInstallTime: DateTime.now().subtract(const Duration(days: 8)),
        customInAppReview: mockInAppReview,
        isTestEnvironment: true,
      );

      final hasPrompted = prefs.getBool('has_been_prompted_for_review') ?? false;
      expect(hasPrompted, isTrue);
      verify(() => mockInAppReview.isAvailable()).called(1);
      verify(() => mockInAppReview.requestReview()).called(1);
    });
  });
}
