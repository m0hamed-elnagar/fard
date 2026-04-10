# Design Spec: Werd History Enhancement

**Date:** 2026-04-10
**Status:** Draft
**Topic:** UI/UX Enhancement of the Werd History Screen

## 1. Objective
Refactor the "Werd History" screen to align with the "Emerald & Gold" design system of the Fard app. The goal is to simplify the visual language, reduce information density, and improve the premium feel of the history log.

## 2. Visual Strategy (UI/UX Best Practices)

### 2.1 Color Palette & Hierarchy
- **Primary Color (Emerald - #2E7D32):** Used for "In Progress" states, navigation buttons, and secondary progress indicators. Represents growth and active reading.
- **Accent Color (Gold - #FFD54F):** Reserved for "Achievement" states (Goal Completed). This provides a clear visual hierarchy and rewards the user for meeting their goal.
- **Surface & Background:** Adhere to `AppTheme.background` (#0D1117) and `AppTheme.surface` (#161B22).
- **Typography Colors:** `textPrimary` (#F0F6FC) for Surah names and main stats; `textSecondary` (#D1D5DA) for timestamps and metadata.

### 2.2 Card Design
- **Radius:** Standardized to **24.0px** (as per `AppTheme.cardTheme`).
- **Border:** Use `AppTheme.cardBorder` (#3D444D) with a width of 1.0px for a subtle "etched" look.
- **Elevation:** 0.0 (Flat design with borders).

## 3. Screen Sections

### 3.1 Month Navigator
- **Container:** `AppTheme.surface` with a 16px radius.
- **Icons:** `Icons.chevron_left/right` in `AppTheme.accent` (Gold).
- **Typography:** Bold `Amiri` for the month/year label.

### 3.2 Monthly Summary (Dashboard Style)
- **Layout:** 3-column grid (Ayahs, Pages, Juz).
- **Consolidation:** Move "Daily Avg" to a subtle gold badge in the top-right corner.
- **Aesthetic:** Borderless flat header to separate it from the scrollable feed.

### 3.3 History Items (Daily Log)
- **Status Indicator:** A single circular icon on the left.
    - Completed: `Icons.check_circle` (Gold).
    - In Progress: `Icons.menu_book` (Emerald).
- **Metadata Row:** Consolidate multiple badges into a single line:
    - Format: `[Icon] Value Unit • [Icon] Value Unit`
    - Example: `📖 15 Ayahs • 📄 2.5 Pages • ⏱️ 1 Session`
- **Progress Bar:** A thin (4px) linear bar at the very bottom of the card.
- **Streak Break:** Subtle 1px divider with a `Icons.pause` or `Icons.link_off` icon in `neutral` gray.

## 4. Interaction & Behavior
- **Expandable Sessions:** Maintain the ability to tap a card to see individual session details (surah/ayah ranges), but only if more than one session exists.
- **Empty State:** A stylized empty state with a "Start Reading" CTA that matches the app's primary button style.

## 5. Success Criteria
- The screen feels like a "natural" part of the Fard app.
- Information is scannable in under 3 seconds.
- The visual "weight" of the screen is reduced by removing redundant box containers.
