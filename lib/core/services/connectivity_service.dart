import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

import 'package:injectable/injectable.dart';

/// Service to monitor network connectivity changes in real-time.
@injectable
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity results.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Returns the current connectivity status.
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Helper to check if there is an active internet connection.
  /// This checks if the device is connected to a network (WiFi/Mobile),
  /// with a robust raw socket lookup fallback if connectivity_plus reports none.
  Future<bool> hasNetwork() async {
    final result = await checkConnectivity();
    if (result.any((r) => r != ConnectivityResult.none)) {
      return true;
    }
    // On mobile devices (Android/iOS), if connectivity_plus reports none,
    // we are definitely offline, so we return false immediately without blocking.
    if (Platform.isAndroid || Platform.isIOS) {
      return false;
    }
    // Fallback if connectivity_plus reports none (e.g. false negative on Windows/VPN)
    return hasInternet();
  }

  /// Checks if the internet is actually reachable.
  /// Uses raw socket connections and DNS lookup in parallel to speed up checking.
  Future<bool> hasInternet() async {
    try {
      final results = await Future.wait([
        verifySocketConnection('8.8.8.8', 53),
        verifySocketConnection('1.1.1.1', 53),
        _verifyDnsLookup('google.com'),
      ]);
      return results.any((r) => r == true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _verifyDnsLookup(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(milliseconds: 1000));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Verifies a raw socket connection to a host/port.
  @visibleForTesting
  Future<bool> verifySocketConnection(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(milliseconds: 1000),
      );
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Legacy helper for backward compatibility, now uses the more robust check.
  Future<bool> hasConnection() => hasInternet();
}
