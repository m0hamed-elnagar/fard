import 'dart:async';
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
  Future<bool> hasConnection() async {
    final result = await checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
