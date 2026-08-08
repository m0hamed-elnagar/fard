import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:fard/core/services/in_app_update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late InAppUpdateService service;

  setUp(() {
    service = InAppUpdateService();
  });

  AppUpdateInfo createMockUpdateInfo({
    required UpdateAvailability availability,
    bool flexibleAllowed = true,
    bool immediateAllowed = true,
  }) {
    return AppUpdateInfo(
      updateAvailability: availability,
      immediateUpdateAllowed: immediateAllowed,
      immediateAllowedPreconditions: const [],
      flexibleUpdateAllowed: flexibleAllowed,
      flexibleAllowedPreconditions: const [],
      availableVersionCode: 100,
      installStatus: InstallStatus.unknown,
      packageName: 'com.khwarizmi.fard',
      clientVersionStalenessDays: 0,
      updatePriority: 0,
    );
  }

  group('InAppUpdateService Tests', () {
    testWidgets('non-Android platform returns safely on silent check', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              service.checkForUpdateSilently(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('non-Android platform shows feedback SnackBar on manual check', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => service.checkForUpdateManually(context),
                  child: const Text('Check Update'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('installUpdateListener stream triggers SnackBar ONLY on InstallStatus.downloaded, not on downloading', (tester) async {
      final streamController = StreamController<InstallStatus>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => service.checkForUpdateSilently(
                    context,
                    customUpdateInfoFetcher: () async => createMockUpdateInfo(
                      availability: UpdateAvailability.updateAvailable,
                    ),
                    customInstallStream: streamController.stream,
                    isTestEnvironment: true,
                  ),
                  child: const Text('Silent Check'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Emit downloading state -> SnackBar should NOT appear
      streamController.add(InstallStatus.downloading);
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);

      // Emit downloaded state -> SnackBar MUST appear with restart action
      streamController.add(InstallStatus.downloaded);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);

      await streamController.close();
    });

    testWidgets('onResumeCheck is strictly gated on developerTriggeredUpdateInProgress', (tester) async {
      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Case A: App update is NOT in progress -> returns false, no stream listener
      final notInProgress = await service.onResumeCheck(
        buildContext,
        customUpdateInfoFetcher: () async => createMockUpdateInfo(
          availability: UpdateAvailability.updateAvailable,
        ),
        isTestEnvironment: true,
      );
      expect(notInProgress, isFalse);

      // Case B: App update IS in progress -> returns true, registers listener
      final inProgress = await service.onResumeCheck(
        buildContext,
        customUpdateInfoFetcher: () async => createMockUpdateInfo(
          availability: UpdateAvailability.developerTriggeredUpdateInProgress,
        ),
        isTestEnvironment: true,
      );
      expect(inProgress, isTrue);
    });
  });
}
