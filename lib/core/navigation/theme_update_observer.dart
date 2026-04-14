import 'package:flutter/material.dart';

/// Tracks active modal/popup route animations and fires [onAllRoutesSettled]
/// once every dismissal animation has fully completed.
class ThemeUpdateObserver extends NavigatorObserver {
  VoidCallback? onAllRoutesSettled;
  int _activeAnimatingRoutes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute || _isModalBottomSheet(route)) {
      _activeAnimatingRoutes++;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute || _isModalBottomSheet(route)) {
      if (route is TransitionRoute) {
        route.completed.then((_) {
          _activeAnimatingRoutes = (_activeAnimatingRoutes - 1).clamp(0, 999);
          if (_activeAnimatingRoutes == 0) {
            onAllRoutesSettled?.call();
          }
        });
      } else {
        _activeAnimatingRoutes = (_activeAnimatingRoutes - 1).clamp(0, 999);
        if (_activeAnimatingRoutes == 0) {
          onAllRoutesSettled?.call();
        }
      }
    }
  }

  bool get hasActiveAnimations => _activeAnimatingRoutes > 0;

  bool _isModalBottomSheet(Route<dynamic> route) =>
      route.runtimeType.toString().contains('ModalBottomSheet');
}
