# Settings Screen Reorganization - Integration Steps

## ✅ What's Already Done:
1. ✅ Backend changes (SettingsState, Repository, Cubit)
2. ✅ Widget theme support (fully working!)
3. ✅ Localization strings added
4. ✅ `_isThemeListExpanded` state variable added to SettingsScreen
5. ✅ All section builder methods created (see settings_sections_to_add.txt)

## 📝 Manual Steps Required:

### Step 1: Add Section Builder Methods
Open: `lib/features/settings/presentation/screens/settings_screen.dart`

1. Go to the end of the file (around line 2445)
2. Find the last closing brace `}` of the class
3. Copy ALL the content from `settings_sections_to_add.txt`
4. Paste it BEFORE the final closing brace `}`

### Step 2: Update the Build Method
In the same file, find the `build` method around line 145.

Look for this section (around line 146):
```dart
children: [
  if (!_canScheduleExactAlarms)
    _buildWarningCard(...),
```

Replace everything from there until the Debug section (around line 620) with:

```dart
children: [
  if (!_canScheduleExactAlarms)
    _buildWarningCard(
      l10n.exactAlarmWarningTitle,
      l10n.exactAlarmWarningDesc,
      Icons.warning_amber_rounded,
    ),
  // Section 1: Appearance
  _buildAppearanceSection(context, state, l10n),
  const SizedBox(height: 20),
  // Section 2: Prayer & Azan
  _buildPrayerAndAzanSection(context, state, l10n),
  const SizedBox(height: 20),
  // Section 3: Azkar
  _buildAzkarSection(context, state, l10n),
  const SizedBox(height: 20),
  // Section 4: General
  _buildGeneralSection(context, state, l10n),
  const SizedBox(height: 20),
  // Section 5: Data & Location
  _buildDataAndLocationSection(context, state, l10n),
  // Debug section stays as is...
```

### Step 3: Test
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 What You'll See:
- **5 organized sections** instead of one long list
- **Expandable theme list** with smooth animation
- **Widget Theme Mode** dropdown (Dark/Light/Follow App)
- **Language toggle** in Appearance section
- **Home widget updates** with chosen theme!

## ⚡ Quick Test Widget Theme:
1. Add prayer widget to home screen
2. Go to Settings → Appearance
3. Change "Widget Theme" to "Light" or "Follow App"
4. Wait 1-5 minutes for widget to refresh
5. Widget will show with new theme!
