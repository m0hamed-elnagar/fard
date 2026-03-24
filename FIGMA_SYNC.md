# Figma Design System Rules - Fard

Use these rules to map Flutter components to Figma nodes using Code Connect.

## Design Tokens

- **Colors:** Defined in `lib/core/theme/app_theme.dart`.
  - `primary`: Emerald Green
  - `accent`: Gold/Amber
  - `background`: Deep Dark
  - `surface`: Dark Navy
- **Typography:** Uses `google_fonts`.
  - Primary: `Outfit`
  - Secondary/Arabic: `Amiri`
- **Spacing:** standard `8dp` increments.
- **Rounding:** 
  - Cards/ExpansionTiles: `24dp`
  - Dialogs: `20dp`
  - Buttons: `12dp`

## Component Mapping

| Flutter Component | Figma Node Name | Location |
| :--- | :--- | :--- |
| `CounterCard` | `CounterCard` | `lib/features/prayer_tracking/presentation/widgets/counter_card.dart` |
| `SalaahTile` | `SalaahTile` | `lib/features/prayer_tracking/presentation/widgets/salaah_tile.dart` |
| `CalendarWidget` | `CalendarWidget` | `lib/features/prayer_tracking/presentation/widgets/calendar_widget.dart` |
| `CustomToggle` | `CustomToggle` | `lib/core/widgets/custom_toggle.dart` |

## Code Connect Patterns

When linking Figma components, use the following template:

```dart
// Code Connect Template
import 'package:fard/features/prayer_tracking/presentation/widgets/counter_card.dart';

// figma.metadata({
//   nodeId: 'YOUR_NODE_ID',
//   label: 'Flutter',
//   componentName: 'CounterCard'
// })
```
