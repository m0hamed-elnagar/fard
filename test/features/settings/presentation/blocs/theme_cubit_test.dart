import 'package:fard/features/settings/presentation/blocs/theme_cubit.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/usecases/apply_theme_preset.dart';
import 'package:fard/features/settings/domain/usecases/save_custom_theme.dart';
import 'package:fard/features/settings/domain/usecases/get_available_theme_presets.dart';
import 'package:fard/features/settings/domain/entities/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockApplyThemePreset extends Mock implements ApplyThemePreset {}
class MockSaveCustomTheme extends Mock implements SaveCustomTheme {}
class MockGetAvailableThemePresets extends Mock implements GetAvailableThemePresets {}

void main() {
  late ThemeCubit cubit;
  late MockSettingsRepository mockRepo;
  late MockApplyThemePreset mockApplyTheme;
  late MockSaveCustomTheme mockSaveCustomTheme;
  late MockGetAvailableThemePresets mockGetPresets;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockApplyTheme = MockApplyThemePreset();
    mockSaveCustomTheme = MockSaveCustomTheme();
    mockGetPresets = MockGetAvailableThemePresets();

    when(() => mockRepo.locale).thenReturn(const Locale('ar'));
    when(() => mockRepo.themePresetId).thenReturn('emerald_gold');
    when(() => mockRepo.customThemeColors).thenReturn(null);
    when(() => mockRepo.savedCustomThemes).thenReturn([]);
    when(() => mockRepo.activeCustomThemeId).thenReturn(null);
    
    when(() => mockRepo.updateLocale(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateThemePreset(any())).thenAnswer((_) async {});
    when(() => mockApplyTheme.execute(any())).thenAnswer((_) async {});

    cubit = ThemeCubit(
      mockRepo,
      mockApplyTheme,
      mockSaveCustomTheme,
      mockGetPresets,
    );
  });

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(CustomTheme.defaultPalette(id: '1', name: '1'));
  });

  group('ThemeCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.themePresetId, 'emerald_gold');
    });

    test('updateLocale updates state and prefs', () async {
      cubit.updateLocale(const Locale('en'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.locale, const Locale('en'));
      verify(() => mockRepo.updateLocale(const Locale('en'))).called(1);
    });

    test('toggleLocale switches between ar and en', () async {
      cubit.toggleLocale();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.locale, const Locale('en'));
      
      cubit.toggleLocale();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.locale, const Locale('ar'));
    });

    test('selectThemePreset calls applyTheme usecase and updates state', () async {
      await cubit.selectThemePreset('ocean_blue');
      expect(cubit.state.themePresetId, 'ocean_blue');
      verify(() => mockApplyTheme.execute('ocean_blue')).called(1);
    });
  });
}
