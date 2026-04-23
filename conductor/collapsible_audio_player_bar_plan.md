# Collapsible Audio Player Bar Plan

## Background & Motivation
The user requested a collapsible audio player bar. The current bar contains too many buttons that crowd the screen and make the Surah/Ayah information hard to read, especially on narrow screens. A collapsible bar will save vertical space by default, showing only the most essential information and controls, and can be expanded by the user to reveal full controls when needed. 

## Scope & Impact
- **State Management:** Add `isPlayerExpanded` to `AudioState` to persist the user's preference during an active playback session. Add a new event to toggle this state.
- **UI Modification:** Refactor `AudioPlayerBar` to support two distinct visual states (Collapsed and Expanded).
  - **Collapsed State (Default):** Ultra-slim progress bar (4px), large Surah/Ayah text, Play/Pause button, and an Expand (Chevron Up) button.
  - **Expanded State:** Full progress bar with time labels, Reciter Avatar, Reciter Name, Surah/Ayah text, and all controls (Location, Repeat, Skip Previous, Play/Pause, Skip Next, Close, and Collapse).

## Implementation Steps

1. **Update `AudioState` (`lib/features/audio/presentation/blocs/audio_state.dart`):**
   - Add `final bool isPlayerExpanded;` with a default value of `false`.
   - Update the `copyWith` method and `props` list to include `isPlayerExpanded`.

2. **Update `AudioEvent` (`lib/features/audio/presentation/blocs/audio_event.dart`):**
   - Add a new event `TogglePlayerExpanded` (or `SetPlayerExpanded(bool isExpanded)`).
   - Update the `AudioEventMapper` extension to include the new event.

3. **Update `AudioBloc` (`lib/features/audio/presentation/blocs/audio_bloc.dart`):**
   - Register a handler for `TogglePlayerExpanded`.
   - On `TogglePlayerExpanded`, emit a new state with the updated `isPlayerExpanded` value.
   - On `HideBanner`, consider resetting `isPlayerExpanded` to `false` so the next time it appears, it starts collapsed.

4. **Refactor `AudioPlayerBar` (`lib/features/audio/presentation/widgets/audio_player_bar.dart`):**
   - Wrap the content in an `AnimatedCrossFade` or `AnimatedSize` to smoothly transition between collapsed and expanded states.
   - **Collapsed View:** 
     - 4px slim slider at the very top.
     - Row containing: Surah/Ayah Text (Expanded), Play/Pause button, and Expand button (`Icons.expand_less`).
   - **Expanded View:**
     - Row with Avatar, Surah/Ayah Text, and Reciter Name.
     - Row with slider and time labels (`--:--`).
     - Row with full control cluster: Location, Repeat, Skip Prev, Play/Pause, Skip Next, Close, and Collapse button (`Icons.expand_more`).

## Verification & Testing
- Start playing an audio file and verify the player bar appears in the collapsed state.
- Verify that only the Play/Pause and Expand buttons are visible, alongside clear Surah/Ayah text.
- Tap the Expand button and verify the bar smoothly expands to show all controls and the reciter information.
- Navigate to another screen (e.g., from Quran to Azkar) and verify the bar remembers its expanded/collapsed state.
- Close the player bar and start a new playback session; verify it resets to the collapsed state.
- Run `flutter analyze` and `flutter test` to ensure no regressions.
