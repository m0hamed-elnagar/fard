import 'package:fard/core/mixins/notification_permission_mixin.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockNotificationService extends Mock implements NotificationService {}

class TestWidget extends StatefulWidget {
  final Function(bool) onResult;
  const TestWidget({super.key, required this.onResult});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> with NotificationPermissionMixin {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final res = await checkAndRequestNotificationPermissions(context);
        widget.onResult(res);
      },
      child: const Text('Check Permissions'),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockNotificationService mockNotificationService;

  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();
    mockNotificationService = MockNotificationService();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  group('NotificationPermissionMixin Tests', () {
    testWidgets('returns true directly if notifications enabled and can schedule', (tester) async {
      when(() => mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
      when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);

      bool? result;
      await tester.pumpWidget(buildTestApp(TestWidget(onResult: (res) => result = res)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check Permissions'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      verify(() => mockNotificationService.areNotificationsEnabled()).called(1);
      verify(() => mockNotificationService.canScheduleExactNotifications()).called(1);
      verifyNever(() => mockNotificationService.requestPermissions());
    });

    testWidgets('shows dialog and returns true if user allows permissions', (tester) async {
      when(() => mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => false);
      when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
      when(() => mockNotificationService.requestPermissions()).thenAnswer((_) async => true);

      bool? result;
      await tester.pumpWidget(buildTestApp(TestWidget(onResult: (res) => result = res)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check Permissions'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Notifications Required'), findsOneWidget);

      // Tap enable
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      verify(() => mockNotificationService.requestPermissions()).called(1);
    });

    testWidgets('shows dialog and returns false if user clicks later/denies', (tester) async {
      when(() => mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
      when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => false);

      bool? result;
      await tester.pumpWidget(buildTestApp(TestWidget(onResult: (res) => result = res)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check Permissions'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Notifications Required'), findsOneWidget);

      // Tap later
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      verifyNever(() => mockNotificationService.requestPermissions());
    });
  });
}
