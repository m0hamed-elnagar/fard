# Wird History Screen - Professional UI/UX Redesign

## 🎨 Design System Enforcement

### Color Roles (Strictly Enforced)

| Color | Hex Code | Role | Usage |
|-------|----------|------|-------|
| **Yellow (Accent)** | `#FFD54F` | Primary Highlights | ✅ Hero numbers, CTAs, active/selected states |
| **Green (Primary)** | `#4CAF50` | Progress & Completion | ✅ Progress bars, checkmarks, positive status |
| **Red (Missed)** | `#F85149` | Interrupted/Missed | ✅ Missed days ONLY, never decorative |
| **White** | `#F0F6FC` | Titles & Key Numbers | ✅ Section headers, primary numbers |
| **Gray (Neutral)** | `#8B949E` | Supporting Info | ✅ Labels, sublabels, metadata |

### What Changed:
- ❌ **Removed**: Green numbers with yellow labels (confusing mix)
- ✅ **Enforced**: Yellow for hero numbers, gray for labels
- ✅ **Consistent**: Every element has ONE clear color role

---

## 📊 Monthly Summary Hero Card

### Before vs After

**Before:**
- Generic gradient background
- Equal visual weight for all stats
- Mixed colors (green icon, yellow border, green numbers)
- No clear hierarchy

**After (Hero Card):**
```
┌─ Yellow Accent Line ─────────────────┐
│ 📊 Monthly Summary                   │
│                                      │
│   📖          📄          📋        │
│  ١٥١٫٩        ١٢          ٣٫٥        │  ← Yellow numbers (30sp, bold)
│  Ayahs       Pages        Juz       │  ← Gray labels (12sp)
│                                      │
│ ───────────────────────────────────  │  ← Subtle divider
│                                      │
│  📈 Daily Avg: ١٢٫٥ pages            │  ← Gray text, surfaceLight bg
└──────────────────────────────────────┘
```

### Design Details:

1. **Yellow Top Accent**: 3px gradient line (yellow → transparent)
2. **Stats Layout**: 
   - Numbers: **Yellow** when selected, **White** when not
   - Labels: **Gray** always (12sp, regular weight)
   - Icon: **Yellow** when selected, **Gray** when not
   - 30sp for big numbers, 12sp for labels
3. **Selection State**: 
   - Selected: Yellow border + yellow text + subtle yellow background (8% alpha)
   - Not selected: Transparent background, white numbers
4. **Average Container**:
   - Background: `surfaceLight` (#21262D)
   - Text: Gray (#8B949E)
   - Icon: Gray (not yellow!)

---

## 📅 Month Navigator

### Before vs After

**Before:**
- Small icon buttons with yellow tint
- Inconsistent spacing
- No visual feedback

**After:**
```
┌──────────────────────────────────────┐
│  ◀      April 2026      ▶    [Current]│
└──────────────────────────────────────┘
```

### Design Details:

1. **Buttons**: 
   - Circular (40x40px)
   - Background: `surfaceLight` (#21262D)
   - Border: `cardBorder` @ 50% alpha
   - Icon: White when enabled, gray @ 50% when disabled
2. **Label**: 
   - Font: Outfit (not Amiri)
   - Size: 16sp, semibold
   - Color: White
3. **Current Badge**:
   - Background: Green @ 15% alpha
   - Border: Green @ 30% alpha
   - Text: Green (#4CAF50), 10sp

---

## 📝 Section Header ("التفاصيل" / "Details")

### Before vs After

**Before:**
- Plain text, no visual distinction
- Mixed font (Amiri)

**After:**
```
┃ Details                        12 days
```

### Design Details:

1. **Yellow Left Bar**: 4px wide, 20px tall, yellow (#FFD54F)
2. **Title Text**: 
   - Font: Outfit (not Amiri)
   - Size: 18sp, semibold
   - Color: White
3. **Days Counter**:
   - Background: `surfaceLight`
   - Border: `cardBorder` @ 30% alpha
   - Text: Gray, 13sp, medium weight
   - Padding: 10x6px

---

## 📖 Detail Day Cards

### Color Simplification

**Before:**
- Mixed green/yellow everywhere
- No clear hierarchy

**After (Strict Color Roles):**
```
┌─────────────────────────────────────┐
│ 📖  Saturday              15.5 Pages│
│     April 5, 2026              78%  │
│                                     │
│  From Al-Baqarah 32 to Al-Imran 10 │  ← Gray metadata
│                                     │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░  (progress bar)│  ← GREEN ONLY
│                                     │
│  [📖 2 sessions] [📄 5.2 pages]    │  ← Badges with Wrap
└─────────────────────────────────────┘
```

### Design Details:

1. **Icon**: 
   - Completed: Yellow checkmark
   - In Progress: Green book icon
2. **Title**: White, 16sp, bold (Amiri for Arabic feel)
3. **Date**: Gray, 13sp
4. **Surah Range**: Gray, 13sp, max 2 lines with ellipsis
5. **Progress Bar**: 
   - Track: `cardBorder` @ 15% alpha
   - Fill: **GREEN ONLY** (#4CAF50)
   - Height: 6px, rounded corners
6. **Badges**: 
   - Wrap layout (no overflow!)
   - Background: Accent @ 10% alpha
   - Text: Accent, 11sp
   - Icon: 12px, same color as text

---

## ⚠️ Interrupted (انقطاع) Badge

### Before vs After

**Before:**
- Harsh red background
- Solid button look
- Clashed with green/yellow palette

**After (Subtle Pill):**
```
────── 🔴 Missed ──────
```

### Design Details:

1. **Background**: Red @ 12% alpha (subtle, not harsh)
2. **Border**: Red @ 30% alpha, 1px width
3. **Icon**: Red (#F85149), 14px
4. **Text**: Red, 12sp, semibold (Outfit)
5. **Gradient Lines**: Red fading to transparent on both sides
6. **Padding**: 14x6px (pill shape, not button)
7. **Vertical Spacing**: 12px above and below

**Color Usage**:
- Red ONLY for missed/interrupted states
- Never decorative
- Low opacity to reduce visual clash

---

## 🎯 Hierarchy Rules Applied

### Text Hierarchy (Clear Scanning)

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| Hero Numbers | Outfit | 30sp+ | 900 (Black) | Yellow |
| Section Headers | Outfit | 18sp | 600 (Semibold) | White |
| Card Titles | Amiri | 16sp | 700 (Bold) | White |
| Metadata (dates, ranges) | Amiri | 13sp | 400 (Regular) | Gray |
| Stat Labels | Outfit | 12sp | 400 (Regular) | Gray |
| Badges | Amiri | 11sp | 500 (Medium) | Accent |

### Spacing Improvements

- ✅ Card padding: 20dp top/bottom (was 16dp)
- ✅ Number-to-label gap: 4dp (was inconsistent)
- ✅ Stat item spacing: 16dp (was 12dp)
- ✅ Section header to content: 16dp (was 12dp)
- ✅ Badge spacing: 8px horizontal, 8px vertical (Wrap)

---

## 🧪 Testing Checklist

- [ ] Hero card numbers in yellow (when selected)
- [ ] Hero card labels in gray (always)
- [ ] Progress bars green ONLY
- [ ] Section header has yellow left bar
- [ ] Month navigator buttons circular (40x40)
- [ ] Interrupted badge subtle (not harsh red)
- [ ] No green/yellow mixing in wrong places
- [ ] Numbers are 30sp+ in hero card
- [ ] Labels are 12sp gray
- [ ] Card padding is 20dp vertical
- [ ] Badge text doesn't overflow
- [ ] Arabic locale renders correctly
- [ ] English locale renders correctly

---

## 📐 Design Philosophy

**"Progressive Disclosure Through Visual Hierarchy"**

1. **Hero Card** (Monthly Summary):
   - Grabs attention with yellow numbers
   - Clearly the most important card
   - Yellow left border = "this is special"

2. **Section Headers**:
   - Yellow left bar creates visual anchor
   - White text on dark background = clear hierarchy
   - Days counter badge = useful metadata

3. **Detail Cards**:
   - Clean, minimal, no yellow
   - Green progress bars = "this is progress"
   - Gray metadata = "supporting info"
   - White titles = "read me first"

4. **Interrupted Badge**:
   - Red but subtle (12% alpha bg)
   - Clear but not jarring
   - Gradient lines blend smoothly

**The result**: A screen where every element has a clear role, users can scan quickly, and the design feels cohesive, not chaotic.

---

## 🎨 Color Palette Reference

```dart
// PRIMARY HIGHLIGHTS
Yellow (accent):     #FFD54F  // Hero numbers, CTAs, selection
Green (primaryLight): #4CAF50  // Progress bars, completion
Red (missed):        #F85149  // Interrupted/missed ONLY

// NEUTRAL COLORS
White (textPrimary): #F0F6FC  // Titles, headers, key numbers
Gray (neutral):      #8B949E  // Labels, metadata, supporting text

// BACKGROUND COLORS
Surface:             #161B22  // Card backgrounds
Surface Light:       #21262D  // Nested containers
Card Border:         #3D444D  // Borders, dividers
```

---

## 📋 Files Modified

- `lib/features/werd/presentation/pages/werd_history_page.dart`
  - Redesigned `_buildSummaryCard` (hero card with yellow accent)
  - Added `_buildHeroStatItem` (30sp numbers, gray labels)
  - Updated `_buildMonthNavigator` (circular buttons)
  - Updated `_buildStreakBreak` (subtle red pill)
  - Enhanced section header (yellow left bar)
  - Enforced color roles throughout

**No changes to `AppTheme`** - only using existing constants.
