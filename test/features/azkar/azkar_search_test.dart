import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}
class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState> implements AzkarBloc {}
class MockNotificationService extends Mock implements NotificationService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
  });

  late MockSettingsCubit mockSettingsCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockNotificationService mockNotificationService;
  late MockVoiceDownloadService mockVoiceDownloadService;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockNotificationService = MockNotificationService();
    mockVoiceDownloadService = MockVoiceDownloadService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);

    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockNotificationService.testReminder(any(), any())).thenAnswer((_) async {});

    when(() => mockSettingsCubit.state).thenReturn(const SettingsState(
      locale: Locale('en'),
      morningAzkarTime: '05:00',
      eveningAzkarTime: '18:00',
      reminders: [],
      isAzanVoiceDownloading: false,
    ));

    when(() => mockAzkarBloc.state).thenReturn(const AzkarState(
      categories: ['Morning Azkar', 'Evening Azkar', 'Sleep Azkar', 'Travel Azkar'],
      azkar: [],
      isLoading: false,
    ));
  });

  group('AzkarCategoriesScreen Search', () {
    Widget createWidgetUnderTest() {
      final getIt = GetIt.instance;
      if (!getIt.isRegistered<NotificationService>()) {
        getIt.registerSingleton<NotificationService>(mockNotificationService);
      }
      if (!getIt.isRegistered<VoiceDownloadService>()) {
        getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
      }
      return MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
          BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: AzkarCategoriesScreen(),
        ),
      );
    }

    testWidgets('filtering categories works', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify all categories are shown initially
      expect(find.text('Morning Azkar'), findsOneWidget);
      expect(find.text('Evening Azkar'), findsOneWidget);
      expect(find.text('Sleep Azkar'), findsOneWidget);
      expect(find.text('Travel Azkar'), findsOneWidget);

      // Tap search button
      await tester.tap(find.byKey(const Key('azkar_search_button')));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byKey(const Key('azkar_search_field')), 'sleep');
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Sleep Azkar'), findsOneWidget);
      expect(find.text('Morning Azkar'), findsNothing);
      expect(find.text('Evening Azkar'), findsNothing);
      expect(find.text('Travel Azkar'), findsNothing);
      
      // Clear search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      
      // Query should be empty but search field still there (based on my impl)
      // Actually my impl: if searching, close clears text.
      expect(find.text('Morning Azkar'), findsOneWidget);
    });
  });

  group('Settings Reminder Search', () {
    Widget createWidgetUnderTest() {
      final getIt = GetIt.instance;
      if (!getIt.isRegistered<NotificationService>()) {
        getIt.registerSingleton<NotificationService>(mockNotificationService);
      }
      if (!getIt.isRegistered<VoiceDownloadService>()) {
        getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
      }
      return MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
          BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: SettingsScreen()),
        ),
      );
    }

    testWidgets('searchable category picker in reminder dialog works', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final addButton = find.byKey(const Key('add_reminder_button'));
      expect(addButton, findsOneWidget);
      
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Add Reminder'), findsOneWidget);

      // Tap the category picker
      await tester.tap(find.ancestor(
        of: find.text('Morning Azkar'),
        matching: find.byWidgetPredicate((widget) => 
          widget is InputDecorator && widget.decoration.labelText == 'Category'),
      )); 
      await tester.pumpAndSettle();

      // Verify bottom sheet is shown with search field
      expect(find.byType(TextField), findsAtLeast(1));
      
      final searchHint = AppLocalizations.of(tester.element(addButton))!.searchCategory;
      expect(find.text(searchHint), findsOneWidget);

      // Filter categories in bottom sheet
      await tester.enterText(find.widgetWithText(TextField, searchHint), 'travel');
      await tester.pumpAndSettle();

      // Verify filtered results in bottom sheet
      expect(find.text('Travel Azkar'), findsOneWidget);

      // Select category
      await tester.tap(find.text('Travel Azkar'));
      await tester.pumpAndSettle();

      // Verify dialog is updated
      expect(find.widgetWithText(InputDecorator, 'Travel Azkar'), findsAtLeast(1));
    });
  });
}
