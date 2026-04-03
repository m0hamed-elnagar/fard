# Enhanced Islamic Prayer Home Widget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance the home widget with a premium Islamic aesthetic, missing data (Sunrise, Day of Week), and robust RTL support.

**Architecture:** Update the Dart data model and update service to provide enriched data, then refactor the Android Jetpack Glance widget to render a responsive, themed UI that adapts to different sizes and locales.

**Tech Stack:** Flutter (Dart), Adhan (Dart), Jetpack Glance (Kotlin), Android (XML Drawables).

---

### Task 1: Update Widget Data Model

**Files:**
- Modify: `lib/core/models/widget_data_model.dart`
- Modify: `lib/core/models/widget_data_model.g.dart` (via code gen)
- Test: `test/core/models/widget_data_model_test.dart`

- [ ] **Step 1: Update `WidgetDataModel` fields**

```dart
@JsonSerializable(explicitToJson: true)
class WidgetDataModel {
  final String gregorianDate;
  final String hijriDate;
  final String dayOfWeek; // New
  final String sunrise; // New
  final bool isRtl; // New
  final List<PrayerTimeItem> prayers;

  WidgetDataModel({
    required this.gregorianDate,
    required this.hijriDate,
    required this.dayOfWeek,
    required this.sunrise,
    required this.isRtl,
    required this.prayers,
  });
  // ... fromJson/toJson
}
```

- [ ] **Step 2: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify with a test**

Create `test/core/models/widget_data_model_test.dart`:
```dart
import 'package:fard/core/models/widget_data_model.dart';
import 'package:test/test.dart';

void main() {
  test('WidgetDataModel should include new fields in JSON', () {
    final model = WidgetDataModel(
      gregorianDate: '29 March 2026',
      hijriDate: '10 Ramadan 1447',
      dayOfWeek: 'Sunday',
      sunrise: '06:00 AM',
      isRtl: false,
      prayers: [],
    );
    final json = model.toJson();
    expect(json['day_of_week'], 'Sunday');
    expect(json['sunrise'], '06:00 AM');
    expect(json['is_rtl'], false);
  });
}
```

- [ ] **Step 4: Run test**

Run: `flutter test test/core/models/widget_data_model_test.dart`

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/widget_data_model.dart lib/core/models/widget_data_model.g.dart
git commit -m "feat(widget): add sunrise, dayOfWeek, and isRtl to data model"
```

---

### Task 2: Enriched Data in WidgetUpdateService

**Files:**
- Modify: `lib/core/services/widget_update_service.dart`
- Test: `test/core/services/widget_update_service_test.dart`

- [ ] **Step 1: Extract enriched data**

In `updateWidget`:
```dart
final sunrise = DateFormat.jm(lang).format(prayerTimes.sunrise);
final dayOfWeek = DateFormat('EEEE', lang).format(now);
final isRtl = lang == 'ar';

final data = WidgetDataModel(
  gregorianDate: DateFormat('d MMMM yyyy', lang).format(now), // Removed EEEE from here
  hijriDate: hijriDate.toVisualString(lang),
  dayOfWeek: dayOfWeek,
  sunrise: sunrise,
  isRtl: isRtl,
  prayers: [ ... ],
);
```

- [ ] **Step 2: Run analysis**

Run: `flutter analyze lib/core/services/widget_update_service.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/widget_update_service.dart
git commit -m "feat(widget): populate new data fields in update service"
```

---

### Task 3: Refactor Android Widget Theme & RTL

**Files:**
- Modify: `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`

- [ ] **Step 1: Define "Midnight Emerald" Theme & RTL State**

In `PrayerWidgetRoot`:
```kotlin
val isRtl = data?.optBoolean("isRtl") ?: false
val bgColor = Color(0xFF0D1B1E) // Deep Emerald/Black
val accentGold = Color(0xFFFFD54F) // Gold
val primaryGreen = Color(0xFF2E7D32) // Emerald Highlight
val textPrimary = Color(0xFFF0F6FC)
val textSecondary = Color(0xFF8B949E)
```

- [ ] **Step 2: Update `PrayerRow` for RTL**

```kotlin
@Composable
private fun PrayerRow(
    name: String, 
    time: String, 
    isHighlighted: Boolean, 
    primaryGreen: Color, 
    textPrimary: Color,
    compact: Boolean,
    isRtl: Boolean
) {
    val arrangement = if (isRtl) Arrangement.End else Arrangement.Start
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .padding(vertical = 1.dp)
            .background(ColorProvider(if (isHighlighted) primaryGreen else Color.Transparent))
            .padding(horizontal = 8.dp, vertical = if (compact) 3.dp else 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (!isRtl) {
            Text(name, modifier = GlanceModifier.defaultWeight(), style = TextStyle(color = ColorProvider(textPrimary)))
            Text(time, style = TextStyle(color = ColorProvider(textPrimary)))
        } else {
            Text(time, style = TextStyle(color = ColorProvider(textPrimary)))
            Text(name, modifier = GlanceModifier.defaultWeight(), style = TextStyle(color = ColorProvider(textPrimary), textAlign = TextAlign.End))
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt
git commit -m "feat(widget): implement Midnight Emerald theme and RTL support"
```

---

### Task 4: Enhance Full Layout (Dates & Sunrise)

**Files:**
- Modify: `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`

- [ ] **Step 1: Update Header with Day of Week**

In `FullLayout`:
```kotlin
val dayOfWeek = data.optString("dayOfWeek")
val hijri = data.optString("hijriDate")
val gregorian = data.optString("gregorianDate")

Column(modifier = GlanceModifier.fillMaxWidth().padding(bottom = 4.dp)) {
    Text(
        text = dayOfWeek,
        style = TextStyle(color = ColorProvider(accentGold), fontSize = 18.sp, fontWeight = FontWeight.Bold)
    )
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        Text(text = "$hijri  |  $gregorian", style = TextStyle(color = ColorProvider(textSecondary), fontSize = 11.sp))
    }
}
```

- [ ] **Step 2: Add Sunrise to the List**

```kotlin
// In FullLayout list loop, insert Sunrise after Fajr
PrayerRow(name = "Fajr", ...)
PrayerRow(name = if (isRtl) "الشروق" else "Sunrise", time = data.optString("sunrise"), ...)
// ... rest of prayers
```

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt
git commit -m "feat(widget): add prominent day of week and sunrise to layout"
```

---

### Task 5: Final Visual Polish & Size Check

**Files:**
- Modify: `android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt`

- [ ] **Step 1: Add Rounded Corners to Root**

```kotlin
// In PrayerWidget.kt (needs Glance 1.1.0+)
Column(
    modifier = GlanceModifier
        .fillMaxSize()
        .background(ColorProvider(bgColor))
        .cornerRadius(16.dp) // Premium rounded look
        .clickable(actionStartActivity<MainActivity>())
        .padding(12.dp),
    ...
)
```

- [ ] **Step 2: Commit**

```bash
git add android/app/src/main/kotlin/com/qada/fard/PrayerWidget.kt
git commit -m "style(widget): add rounded corners and padding adjustments"
```
