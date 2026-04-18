import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity changes in real-time.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity results.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Returns the current connectivity status.
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Helper to check if there is an active internet connection.
  /// This only checks if the device is connected to a network (WiFi/Mobile),
  /// not if the internet is actually reachable.
  Future<bool> hasNetwork() async {
    final result = await checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Checks if the internet is actually reachable.
  Future<bool> hasInternet() async {
    if (!await hasNetwork()) return false;

    try {
      // Try to look up a reliable domain
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Legacy helper for backward compatibility, now uses the more robust check.
  Future<bool> hasConnection() => hasInternet();
}
